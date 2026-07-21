module fifo #(
    parameter DATA_WIDTH   = 32,
    parameter ADDR_WIDTH   = 32,
    parameter DEPTH        = 8,
    parameter PTR_WIDTH    = 3
) (
    input  wire                      clk_i,
    input  wire                      rst_n_i,

    // Producer Push Interface
    input  wire                      fifo_push_i,
    input  wire [ADDR_WIDTH-1:0]     fifo_addr_i,
    input  wire                      fifo_write_i,
    input  wire [DATA_WIDTH-1:0]     fifo_wdata_i,
    input  wire [2:0]                fifo_size_i,
    input  wire [2:0]                fifo_burst_i,
    input  wire [7:0]                fifo_burst_len_i,
    output wire                      fifo_full_o,

    // Consumer Pop Interface
    input  wire                      fifo_pop_i,
    output wire [ADDR_WIDTH-1:0]     fifo_addr_o,
    output wire                      fifo_write_o,
    output wire [DATA_WIDTH-1:0]     fifo_wdata_o,
    output wire [2:0]                fifo_size_o,
    output wire [2:0]                fifo_burst_o,
    output wire [7:0]                fifo_burst_len_o,
    output wire                      fifo_empty_o
);

    localparam ENTRY_WIDTH = ADDR_WIDTH + 1 + DATA_WIDTH + 3 + 3 + 8;

    reg [ENTRY_WIDTH-1:0] mem [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;
    reg [PTR_WIDTH:0]   fifo_count;

    assign fifo_empty_o = (fifo_count == {(PTR_WIDTH+1){1'b0}});
    assign fifo_full_o  = (fifo_count == DEPTH[PTR_WIDTH:0]);

    wire [ENTRY_WIDTH-1:0] entry_in;
    assign entry_in = {fifo_addr_i, fifo_write_i, fifo_wdata_i,
                        fifo_size_i, fifo_burst_i, fifo_burst_len_i};

    wire [ENTRY_WIDTH-1:0] entry_out;
    assign entry_out = mem[rd_ptr];

    assign fifo_addr_o      = entry_out[ENTRY_WIDTH-1 -: ADDR_WIDTH];
    assign fifo_write_o     = entry_out[DATA_WIDTH+3+3+8];
    assign fifo_wdata_o     = entry_out[DATA_WIDTH+3+3+8-1 -: DATA_WIDTH];
    assign fifo_size_o      = entry_out[13:11];
    assign fifo_burst_o     = entry_out[10:8];
    assign fifo_burst_len_o = entry_out[7:0];

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            wr_ptr <= {PTR_WIDTH{1'b0}};
        end else if (fifo_push_i && !fifo_full_o) begin
            mem[wr_ptr] <= entry_in;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rd_ptr <= {PTR_WIDTH{1'b0}};
        end else if (fifo_pop_i && !fifo_empty_o) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            fifo_count <= {(PTR_WIDTH+1){1'b0}};
        end else begin
            case ({(fifo_push_i && !fifo_full_o), (fifo_pop_i && !fifo_empty_o)})
                2'b10: fifo_count <= fifo_count + 1'b1;
                2'b01: fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

endmodule