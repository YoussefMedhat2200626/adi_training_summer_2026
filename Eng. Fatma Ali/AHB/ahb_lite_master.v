`timescale 1ns/1ps

module ahb_lite_master (
    input  wire        HCLK,
    input  wire        HRESETn,

    // --- User Command Interface ---
    input  wire        cmd_valid,
    input  wire [31:0] cmd_addr,
    input  wire        cmd_write,
    input  wire [2:0]  cmd_size,    // 000: Byte, 001: Halfword, 010: Word
    input  wire [2:0]  cmd_burst,
    input  wire        cmd_lock,
    input  wire [31:0] cmd_wdata,
    input  wire        cmd_busy,
    output reg         cmd_ready,

    // --- AHB-Lite Master Bus Interface ---
    output wire [31:0] HADDR,
    output wire        HWRITE,
    output wire [2:0]  HSIZE,
    output wire [2:0]  HBURST,
    output wire [1:0]  HTRANS,      
    output wire        HMASTLOCK,
    output reg  [31:0] HWDATA,
    input  wire [31:0] HRDATA,
    input  wire        HREADY,
    input  wire        HRESP
);

    // FSM States
    localparam [1:0] ST_IDLE   = 2'b00,
                     ST_BUSY   = 2'b01,
                     ST_NONSEQ = 2'b10,
                     ST_SEQ    = 2'b11;

    reg [1:0] current_state, next_state;
    reg [4:0] beat_cnt, next_beat_cnt;
    reg [31:0] current_wdata, next_wdata;

    reg [31:0] haddr_reg;
    reg        hwrite_reg;
    reg [2:0]  hsize_reg;
    reg [2:0]  hburst_reg;
    reg        hmastlock_reg;

    // --------------------------------------------------------
    // 0-Latency Combinatorial Bypass
    // --------------------------------------------------------
    wire start_transfer = (current_state == ST_IDLE && cmd_valid);
    
    assign HTRANS    = start_transfer ? ST_NONSEQ : current_state;
    assign HADDR     = start_transfer ? cmd_addr  : haddr_reg;
    assign HWRITE    = start_transfer ? cmd_write : hwrite_reg;
    assign HSIZE     = start_transfer ? cmd_size  : hsize_reg;
    assign HBURST    = start_transfer ? cmd_burst : hburst_reg;
    assign HMASTLOCK = start_transfer ? cmd_lock  : hmastlock_reg;

    // Automatic Address Calculator
    function [31:0] calc_next_addr(
        input [31:0] curr_addr,
        input [2:0]  size,
        input [2:0]  burst
    );
        reg [31:0] inc;
        reg [31:0] wrap_mask;
        reg [31:0] base_addr;
        reg [31:0] offset;
        begin
            inc = (32'd1 << size);
            case (burst)
                3'b010: wrap_mask = (32'd4  << size) - 1'b1; // WRAP4
                3'b100: wrap_mask = (32'd8  << size) - 1'b1; // WRAP8
                3'b110: wrap_mask = (32'd16 << size) - 1'b1; // WRAP16
                default: wrap_mask = 32'd0;                  // INCR / SINGLE
            endcase

            if (burst == 3'b010 || burst == 3'b100 || burst == 3'b110) begin
                base_addr = curr_addr & ~wrap_mask;
                offset    = ((curr_addr & wrap_mask) + inc) & wrap_mask;
                calc_next_addr = base_addr | offset;
            end else begin
                calc_next_addr = curr_addr + inc;
            end
        end
    endfunction

    // Sequential State Logic
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= ST_IDLE;
            beat_cnt      <= 5'd0;
            current_wdata <= 32'd0;
        end else begin
            current_state <= next_state;
            beat_cnt      <= next_beat_cnt;
            current_wdata <= next_wdata;
        end
    end

    // Next-State Combinational Logic
    always @(*) begin
        next_state    = current_state;
        next_beat_cnt = beat_cnt;
        next_wdata    = current_wdata;
        cmd_ready     = 1'b0;

        case (current_state)
            ST_IDLE: begin
                cmd_ready = 1'b1;
                if (cmd_valid) begin
                    next_wdata = cmd_wdata; 
                    case (cmd_burst)
                        3'b000: begin // SINGLE
                            next_beat_cnt = 5'd0;  
                            next_state    = ST_IDLE; 
                        end
                        3'b010, 3'b011: begin // WRAP4 / INCR4
                            next_beat_cnt = 5'd3;  
                            next_state    = ST_SEQ;
                        end
                        3'b100, 3'b101: begin // WRAP8 / INCR8
                            next_beat_cnt = 5'd7;  
                            next_state    = ST_SEQ;
                        end
                        3'b110, 3'b111: begin // WRAP16 / INCR16
                            next_beat_cnt = 5'd15; 
                            next_state    = ST_SEQ;
                        end
                        default: begin
                            next_beat_cnt = 5'd0;
                            next_state    = ST_IDLE;
                        end
                    endcase
                end
            end

            ST_SEQ: begin
                if (HREADY) begin
                    if (HRESP) begin
                        next_state = ST_IDLE;
                    end else if (cmd_busy) begin
                        next_wdata    = current_wdata + 32'd1;
                        next_beat_cnt = beat_cnt - 5'd1;
                        next_state    = ST_BUSY;
                    end else begin
                        next_wdata    = current_wdata + 32'd1;
                        next_beat_cnt = beat_cnt - 5'd1;
                        if (beat_cnt == 5'd1) begin
                            next_state = ST_IDLE;
                        end
                    end
                end
            end

            ST_BUSY: begin
                if (!cmd_busy) begin
                    if (beat_cnt == 5'd0)
                        next_state = ST_IDLE;
                    else
                        next_state = ST_SEQ;
                end
            end

            default: next_state = ST_IDLE;
        endcase
    end

    // Sequential Tracking for Address & Control Signals
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            haddr_reg     <= 32'd0;
            hwrite_reg    <= 1'b0;
            hsize_reg     <= 3'd0;
            hburst_reg    <= 3'd0;
            hmastlock_reg <= 1'b0;
        end else if (start_transfer) begin
            hwrite_reg    <= cmd_write;
            hsize_reg     <= cmd_size;
            hburst_reg    <= cmd_burst;
            hmastlock_reg <= cmd_lock;
            
            if (cmd_burst != 3'b000) begin
                haddr_reg <= calc_next_addr(cmd_addr, cmd_size, cmd_burst);
            end else begin
                haddr_reg <= cmd_addr;
            end
            
        end else if (current_state == ST_SEQ && HREADY && !HRESP && (beat_cnt > 1)) begin
            haddr_reg <= calc_next_addr(HADDR, HSIZE, HBURST);
        end
    end

    // HWDATA Output Generation
    always @(*) begin
        HWDATA = HWRITE ? current_wdata : 32'd0;
    end

endmodule