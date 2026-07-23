

`timescale 1ns / 1ps

module ahb_slave_bfm
    import ahb_lite_pkg::*;
(
    input  logic        HCLK,
    input  logic        HRESETn,

        input  logic [31:0] HADDR,
    input  logic [31:0] HWDATA,
    input  logic        HWRITE,
    input  logic [2:0]  HSIZE,
    input  logic [2:0]  HBURST,
    input  logic [1:0]  HTRANS,

    output logic [31:0] HRDATA,
    input  logic        HREADYIN,
    output logic        HREADYOUT,
    output logic        HRESP
);

    logic [31:0] mem [0:255];

    int          wait_state_count = 0;      
    logic [31:0] error_addr       = 32'hFFFF_FFFF;  
    logic        error_inject_en  = 1'b0;   

    logic        valid_transfer;
    logic        wr_en_r;
    logic [7:0]  addr_word_r;
    logic [2:0]  hsize_r;
    logic [1:0]  addr_byte_r;
    logic        error_pending;

    assign valid_transfer = HREADYIN && (HTRANS == HTRANS_NONSEQ || HTRANS == HTRANS_SEQ);

    int wait_cnt;

    typedef enum logic [1:0] {
        S_READY,
        S_WAIT,
        S_ERR_CYCLE1,
        S_ERR_CYCLE2
    } bfm_state_t;

    bfm_state_t bfm_state;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            bfm_state    <= S_READY;
            wr_en_r      <= 1'b0;
            addr_word_r  <= 8'd0;
            hsize_r      <= HSIZE_WORD;
            addr_byte_r  <= 2'b00;
            error_pending <= 1'b0;
            wait_cnt     <= 0;
        end else begin
            case (bfm_state)
                S_READY: begin
                    if (valid_transfer) begin
                        
                        if (error_inject_en && (HADDR == error_addr)) begin
                            $display("SLAVE DEBUG: Error triggered for address %h", HADDR);
                            error_pending <= 1'b1;
                            bfm_state     <= S_ERR_CYCLE1;
                            
                            wr_en_r     <= HWRITE;
                            addr_word_r <= HADDR[9:2];
                            hsize_r     <= HSIZE;
                            addr_byte_r <= HADDR[1:0];
                        end else if (wait_state_count > 0) begin
                            
                            wait_cnt    <= wait_state_count;
                            bfm_state   <= S_WAIT;
                            
                            wr_en_r     <= HWRITE;
                            addr_word_r <= HADDR[9:2];
                            hsize_r     <= HSIZE;
                            addr_byte_r <= HADDR[1:0];
                        end else begin
                            
                            wr_en_r     <= HWRITE;
                            addr_word_r <= HADDR[9:2];
                            hsize_r     <= HSIZE;
                            addr_byte_r <= HADDR[1:0];
                            error_pending <= 1'b0;
                        end
                    end else begin
                        wr_en_r       <= 1'b0;
                        error_pending <= 1'b0;
                    end
                end

                S_WAIT: begin
                    if (wait_cnt > 1) begin
                        wait_cnt <= wait_cnt - 1;
                    end else begin
                        wait_cnt  <= 0;
                        bfm_state <= S_READY;
                    end
                end

                S_ERR_CYCLE1: begin
                    
                    bfm_state <= S_ERR_CYCLE2;
                end

                S_ERR_CYCLE2: begin
                    
                    bfm_state     <= S_READY;
                    wr_en_r       <= 1'b0;
                    error_pending <= 1'b0;
                end

                default: bfm_state <= S_READY;
            endcase
        end
    end

    always_comb begin
        case (bfm_state)
            S_READY: begin
                HREADYOUT = 1'b1;
                HRESP     = 1'b0;
            end
            S_WAIT: begin
                HREADYOUT = 1'b0;
                HRESP     = 1'b0;
            end
            S_ERR_CYCLE1: begin
                HREADYOUT = 1'b0;
                HRESP     = 1'b1;
            end
            S_ERR_CYCLE2: begin
                HREADYOUT = 1'b1;
                HRESP     = 1'b1;
            end
            default: begin
                HREADYOUT = 1'b1;
                HRESP     = 1'b0;
            end
        endcase
    end

    logic [3:0] byte_en;

    always_comb begin
        byte_en = 4'b0000;
        case (hsize_r)
            HSIZE_BYTE: begin
                case (addr_byte_r)
                    2'b00: byte_en = 4'b0001;
                    2'b01: byte_en = 4'b0010;
                    2'b10: byte_en = 4'b0100;
                    2'b11: byte_en = 4'b1000;
                endcase
            end
            HSIZE_HALF: begin
                case (addr_byte_r[1])
                    1'b0: byte_en = 4'b0011;
                    1'b1: byte_en = 4'b1100;
                endcase
            end
            HSIZE_WORD:  byte_en = 4'b1111;
            default:     byte_en = 4'b1111;
        endcase
    end

    always_ff @(posedge HCLK) begin
        if (wr_en_r && HREADYOUT && (bfm_state == S_READY)) begin
            if (byte_en[0]) mem[addr_word_r][7:0]   <= HWDATA[7:0];
            if (byte_en[1]) mem[addr_word_r][15:8]  <= HWDATA[15:8];
            if (byte_en[2]) mem[addr_word_r][23:16] <= HWDATA[23:16];
            if (byte_en[3]) mem[addr_word_r][31:24] <= HWDATA[31:24];
        end
    end

    assign HRDATA = mem[addr_word_r];

    initial begin
        for (int i = 0; i < 256; i++)
            mem[i] = 32'h0;
    end

endmodule
