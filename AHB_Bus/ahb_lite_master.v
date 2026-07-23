
module ahb_lite_master #(
    parameter AW        = 32,
    parameter DW        = 32,
    parameter MAX_BEATS = 16
) (
    input  wire            HCLK,
    input  wire            HRESETn,

    
    output reg  [AW-1:0]   HADDR,
    output reg             HWRITE,
    output reg  [2:0]      HSIZE,
    output reg  [2:0]      HBURST,
    output reg  [1:0]      HTRANS,
    output reg  [DW-1:0]   HWDATA,

    
    input  wire            HREADY,
    input  wire            HRESP,
    input  wire [DW-1:0]   HRDATA,

    
    input  wire                        start,      
    input  wire                        wr_en,      
    input  wire [AW-1:0]               start_addr,
    input  wire [2:0]                  burst_type, 
    input  wire [MAX_BEATS*DW-1:0]     wdata_bus,  
                                                    
    output reg                         busy,
    output reg                         done,       
    output reg                         error,     

    
    output reg             rdata_valid, 
    output reg  [DW-1:0]   rdata_out,
    output reg  [3:0]      rbeat_num
);

    
    localparam [1:0] TRANS_IDLE   = 2'b00;
    localparam [1:0] TRANS_NONSEQ = 2'b10;
    localparam [1:0] TRANS_SEQ    = 2'b11;

    
    localparam [2:0] BURST_SINGLE = 3'b000;
    localparam [2:0] BURST_INCR4  = 3'b011;
    localparam [2:0] BURST_INCR8  = 3'b101;
    localparam [2:0] BURST_INCR16 = 3'b111;

    localparam [2:0] HSIZE_WORD   = 3'b010;

    
    localparam [2:0] S_IDLE   = 3'd0;
    localparam [2:0] S_NONSEQ = 3'd1;
    localparam [2:0] S_SEQ    = 3'd2;
    localparam [2:0] S_LAST   = 3'd3;
    localparam [2:0] S_DONE   = 3'd4;
    localparam [2:0] S_ERROR  = 3'd5;

    reg [2:0]  state;
    reg [4:0]  num_beats;   
    reg [4:0]  beat_cnt;    
    reg        write_reg;

    
    reg        dp_valid;
    reg        dp_write;
    reg [4:0]  dp_beat;

    function [4:0] beats_of_burst;
        input [2:0] bt;
        begin
            case (bt)
                BURST_SINGLE: beats_of_burst = 5'd1;
                BURST_INCR4:  beats_of_burst = 5'd4;
                BURST_INCR8:  beats_of_burst = 5'd8;
                BURST_INCR16: beats_of_burst = 5'd16;
                default:      beats_of_burst = 5'd1; 
            endcase
        end
    endfunction

    
    function [DW-1:0] wdata_of_beat;
        input [4:0] b;
        begin
            wdata_of_beat = wdata_bus[b*DW +: DW];
        end
    endfunction

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state       <= S_IDLE;
            HADDR       <= 'b0;
            HWRITE      <= 1'b0;
            HSIZE       <= HSIZE_WORD;
            HBURST      <= BURST_SINGLE;
            HTRANS      <= TRANS_IDLE;
            HWDATA      <= 'b0;
            beat_cnt    <= 5'd0;
            num_beats   <= 5'd1;
            write_reg   <= 1'b0;
            dp_valid    <= 1'b0;
            dp_write    <= 1'b0;
            dp_beat     <= 5'd0;
            busy        <= 1'b0;
            done        <= 1'b0;
            error       <= 1'b0;
            rdata_valid <= 1'b0;
            rdata_out   <= 'b0;
            rbeat_num   <= 4'd0;
        end else begin
            
            done        <= 1'b0;
            error       <= 1'b0;
            rdata_valid <= 1'b0;

            
            
            if (dp_valid && HREADY && !dp_write) begin
                rdata_valid <= 1'b1;
                rdata_out   <= HRDATA;
                rbeat_num   <= dp_beat[3:0];
            end

            case (state)
                
                S_IDLE: begin
                    busy     <= 1'b0;
                    HTRANS   <= TRANS_IDLE;
                    dp_valid <= 1'b0;
                    if (start) begin
                        HADDR     <= start_addr;
                        HWRITE    <= wr_en;
                        write_reg <= wr_en;
                        HBURST    <= burst_type;
                        HSIZE     <= HSIZE_WORD;
                        num_beats <= beats_of_burst(burst_type);
                        beat_cnt  <= 5'd0;
                        HTRANS    <= TRANS_NONSEQ;
                        busy      <= 1'b1;
                        state     <= S_NONSEQ;
                    end
                end

                
                S_NONSEQ: begin
                    if (HREADY) begin
                        if (HRESP) begin
                            HTRANS <= TRANS_IDLE;
                            state  <= S_ERROR;
                        end else begin
                            dp_valid <= 1'b1;
                            dp_write <= write_reg;
                            dp_beat  <= beat_cnt;                
                            if (write_reg)
                                HWDATA <= wdata_of_beat(beat_cnt); 
                            if (num_beats > 1) begin
                                HADDR    <= HADDR + (DW/8);
                                beat_cnt <= beat_cnt + 1'b1;
                                HTRANS   <= TRANS_SEQ;
                                state    <= S_SEQ;
                            end else begin
                                HTRANS <= TRANS_IDLE;
                                state  <= S_LAST;
                            end
                        end
                    end
                end

            
                S_SEQ: begin
                    if (HREADY) begin
                        if (HRESP) begin
                  
                            HTRANS <= TRANS_IDLE;
                            state  <= S_ERROR;
                        end else begin
                            dp_valid <= 1'b1;
                            dp_write <= write_reg;
                            dp_beat  <= beat_cnt;
                            if (write_reg)
                                HWDATA <= wdata_of_beat(beat_cnt);
                            if (beat_cnt < num_beats - 1) begin
                                HADDR    <= HADDR + (DW/8);
                                beat_cnt <= beat_cnt + 1'b1;
                            end else begin
                                HTRANS <= TRANS_IDLE;
                                state  <= S_LAST;
                            end
                        end
                    end
                end

          
                S_LAST: begin
                    if (HREADY) begin
                        if (HRESP) begin
                            state <= S_ERROR;
                        end else begin
                            dp_valid <= 1'b0;
                            state    <= S_DONE;
                        end
                    end
                end


                S_DONE: begin
                    done  <= 1'b1;
                    busy  <= 1'b0;
                    state <= S_IDLE;
                end


                S_ERROR: begin
                    error    <= 1'b1;
                    busy     <= 1'b0;
                    dp_valid <= 1'b0;
                    HTRANS   <= TRANS_IDLE;
                    state    <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
