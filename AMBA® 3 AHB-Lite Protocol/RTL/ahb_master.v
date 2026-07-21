module ahb_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                      hclk_i,
    input  wire                      hresetn_i,

    //--------------------------------------------------------------------
    // AHB-Lite Master Interface
    //--------------------------------------------------------------------
    output reg  [ADDR_WIDTH-1:0]     haddr_o,
    output reg  [1:0]                htrans_o,
    output reg  [2:0]                hburst_o,
    output reg  [2:0]                hsize_o,
    output reg                       hwrite_o,
    output wire [3:0]                hprot_o,      // Permanently 4'b0000
    output wire                      hmastlock_o,  // Permanently 1'b0
    output reg  [DATA_WIDTH-1:0]     hwdata_o,

    input  wire                      hready_i,
    input  wire                      hresp_i,      // Ignored (OKAY only supported)
    input  wire [DATA_WIDTH-1:0]     hrdata_i,

    //--------------------------------------------------------------------
    // FIFO Interface (Consumer Side)
    //--------------------------------------------------------------------
    input  wire                      fifo_empty_i,
    input  wire [ADDR_WIDTH-1:0]     fifo_addr_i,
    input  wire                      fifo_write_i,
    input  wire [DATA_WIDTH-1:0]     fifo_wdata_i,
    input  wire [2:0]                fifo_size_i,
    input  wire [2:0]                fifo_burst_i,
    input  wire [7:0]                fifo_burst_len_i,
    output reg                       fifo_pop_o,

    //--------------------------------------------------------------------
    // Read Data Capture
    //--------------------------------------------------------------------
    output reg  [DATA_WIDTH-1:0]     rdata_o,
    output reg                       rdata_valid_o
);

    // AHB Local Constants
    localparam [1:0] HTRANS_IDLE   = 2'b00;
    localparam [1:0] HTRANS_NONSEQ = 2'b10;
    localparam [1:0] HTRANS_SEQ    = 2'b11;

    localparam [2:0] HBURST_SINGLE = 3'b000;
    localparam [2:0] HSIZE_WORD     = 3'b010;

    // FSM States
    localparam [1:0] S_IDLE      = 2'd0,
                     S_TRANSFER  = 2'd1,
                     S_LAST_DATA = 2'd2;

    reg [1:0] state, next_state;

    // Disabled features tied off
    assign hprot_o     = 4'b0000;
    assign hmastlock_o = 1'b0;

    // Request latch registers
    reg                  req_write_r;
    reg [DATA_WIDTH-1:0] req_wdata_r;
    reg [2:0]            req_size_r;
    reg [7:0]            req_burst_len_r;
    reg [7:0]            beat_cnt_r;

    // Address step based on size (WORD = +4, HALFWORD = +2)
    wire [ADDR_WIDTH-1:0] addr_step;
    assign addr_step = (req_size_r == HSIZE_WORD) ? 32'd4 : 32'd2;

    // Data-phase pipeline registers
    reg                  ph_valid_r;
    reg                  ph_write_r;
    reg [DATA_WIDTH-1:0] ph_wdata_r;

    wire is_last_beat;
    assign is_last_beat = (beat_cnt_r == req_burst_len_r);

    // Sequential State Logic
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Next-State Combinational Logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (!fifo_empty_i)
                    next_state = S_TRANSFER;
            end

            S_TRANSFER: begin
                if (hready_i) begin
                    if (is_last_beat)
                        next_state = S_LAST_DATA;
                    else
                        next_state = S_TRANSFER;
                end
            end

            S_LAST_DATA: begin
                if (hready_i)
                    next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Latch Request Parameters from FIFO
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            req_write_r     <= 1'b0;
            req_wdata_r     <= {DATA_WIDTH{1'b0}};
            req_size_r      <= HSIZE_WORD;
            req_burst_len_r <= 8'd1;
        end else if (state == S_IDLE && !fifo_empty_i) begin
            req_write_r     <= fifo_write_i;
            req_wdata_r     <= fifo_wdata_i;
            req_size_r      <= fifo_size_i;
            req_burst_len_r <= (fifo_burst_i == HBURST_SINGLE) ? 8'd1 :
                               (fifo_burst_len_i == 8'd0)      ? 8'd1 : fifo_burst_len_i;
        end
    end

    // Address & Control Signals Drive Logic
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            haddr_o    <= {ADDR_WIDTH{1'b0}};
            htrans_o   <= HTRANS_IDLE;
            hburst_o   <= HBURST_SINGLE;
            hsize_o    <= HSIZE_WORD;
            hwrite_o   <= 1'b0;
            beat_cnt_r <= 8'd1;
        end else begin
            case (state)
                S_IDLE: begin
                    if (!fifo_empty_i) begin
                        haddr_o    <= fifo_addr_i;
                        htrans_o   <= HTRANS_NONSEQ;
                        hburst_o   <= fifo_burst_i;
                        hsize_o    <= fifo_size_i;
                        hwrite_o   <= fifo_write_i;
                        beat_cnt_r <= 8'd1;
                    end else begin
                        htrans_o   <= HTRANS_IDLE;
                    end
                end

                S_TRANSFER: begin
                    if (hready_i) begin
                        if (!is_last_beat) begin
                            haddr_o    <= haddr_o + addr_step;
                            htrans_o   <= HTRANS_SEQ;
                            beat_cnt_r <= beat_cnt_r + 8'd1;
                        end else begin
                            htrans_o   <= HTRANS_IDLE;
                        end
                    end
                end

                S_LAST_DATA: begin
                    htrans_o <= HTRANS_IDLE;
                end

                default: htrans_o <= HTRANS_IDLE;
            endcase
        end
    end

    // Data-Phase Pipeline Tracking
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            ph_valid_r <= 1'b0;
            ph_write_r <= 1'b0;
            ph_wdata_r <= {DATA_WIDTH{1'b0}};
        end else if (hready_i) begin
            if (state == S_TRANSFER) begin
                ph_valid_r <= 1'b1;
                ph_write_r <= req_write_r;
                ph_wdata_r <= req_wdata_r;
            end else begin
                ph_valid_r <= 1'b0;
            end
        end
    end

    always @(*) begin
        hwdata_o = ph_wdata_r;
    end

    // Read Data Capture
    always @(posedge hclk_i or negedge hresetn_i) begin
        if (!hresetn_i) begin
            rdata_o       <= {DATA_WIDTH{1'b0}};
            rdata_valid_o <= 1'b0;
        end else begin
            rdata_valid_o <= 1'b0;
            if (hready_i && ph_valid_r && !ph_write_r) begin
                rdata_o       <= hrdata_i;
                rdata_valid_o <= 1'b1;
            end
        end
    end

    // Pop FIFO on Final Data Phase Completion
    always @(*) begin
        fifo_pop_o = (state == S_LAST_DATA) && hready_i;
    end

endmodule