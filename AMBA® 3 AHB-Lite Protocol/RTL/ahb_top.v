module ahb_top #(
    parameter ADDR_WIDTH      = 32,
    parameter DATA_WIDTH      = 32,
    parameter FIFO_DEPTH      = 8,
    parameter FIFO_PTR_WIDTH  = 3,
    parameter MEM_DEPTH_BYTES = 4096,
    parameter WAIT_THRESHOLD  = 32'h00000100,
    parameter WAIT_CYCLES     = 2
) (
    input  wire                      hclk_i,
    input  wire                      hresetn_i,

    // FIFO Interface
    input  wire                      fifo_push_i,
    input  wire [ADDR_WIDTH-1:0]     fifo_addr_i,
    input  wire                      fifo_write_i,
    input  wire [DATA_WIDTH-1:0]     fifo_wdata_i,
    input  wire [2:0]                fifo_size_i,
    input  wire [2:0]                fifo_burst_i,
    input  wire [7:0]                fifo_burst_len_i,
    output wire                      fifo_full_o,

    // Read Data Capture Output
    output wire [DATA_WIDTH-1:0]     rdata_o,
    output wire                      rdata_valid_o
);

    wire                  fifo_empty;
    wire [ADDR_WIDTH-1:0] fifo_out_addr;
    wire                  fifo_out_write;
    wire [DATA_WIDTH-1:0] fifo_out_wdata;
    wire [2:0]            fifo_out_size;
    wire [2:0]            fifo_out_burst;
    wire [7:0]            fifo_out_burst_len;
    wire                  fifo_pop;

    wire [ADDR_WIDTH-1:0] haddr;
    wire [1:0]            htrans;
    wire [2:0]            hburst;
    wire [2:0]            hsize;
    wire                  hwrite;
    wire [3:0]            hprot;
    wire                  hmastlock;
    wire [DATA_WIDTH-1:0] hwdata;

    wire                  hreadyout;
    wire                  hresp;
    wire [DATA_WIDTH-1:0] hrdata;

    fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DEPTH      (FIFO_DEPTH),
        .PTR_WIDTH  (FIFO_PTR_WIDTH)
    ) u_fifo (
        .clk_i            (hclk_i),
        .rst_n_i          (hresetn_i),

        .fifo_push_i      (fifo_push_i),
        .fifo_addr_i      (fifo_addr_i),
        .fifo_write_i     (fifo_write_i),
        .fifo_wdata_i     (fifo_wdata_i),
        .fifo_size_i      (fifo_size_i),
        .fifo_burst_i     (fifo_burst_i),
        .fifo_burst_len_i (fifo_burst_len_i),
        .fifo_full_o      (fifo_full_o),

        .fifo_pop_i       (fifo_pop),
        .fifo_addr_o      (fifo_out_addr),
        .fifo_write_o     (fifo_out_write),
        .fifo_wdata_o     (fifo_out_wdata),
        .fifo_size_o      (fifo_out_size),
        .fifo_burst_o     (fifo_out_burst),
        .fifo_burst_len_o (fifo_out_burst_len),
        .fifo_empty_o     (fifo_empty)
    );

    ahb_master #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_ahb_master (
        .hclk_i          (hclk_i),
        .hresetn_i       (hresetn_i),

        .haddr_o         (haddr),
        .htrans_o        (htrans),
        .hburst_o        (hburst),
        .hsize_o         (hsize),
        .hwrite_o        (hwrite),
        .hprot_o         (hprot),
        .hmastlock_o     (hmastlock),
        .hwdata_o        (hwdata),

        .hready_i        (hreadyout),
        .hresp_i         (hresp),
        .hrdata_i        (hrdata),

        .fifo_empty_i     (fifo_empty),
        .fifo_addr_i      (fifo_out_addr),
        .fifo_write_i     (fifo_out_write),
        .fifo_wdata_i     (fifo_out_wdata),
        .fifo_size_i      (fifo_out_size),
        .fifo_burst_i     (fifo_out_burst),
        .fifo_burst_len_i (fifo_out_burst_len),
        .fifo_pop_o       (fifo_pop),

        .rdata_o          (rdata_o),
        .rdata_valid_o    (rdata_valid_o)
    );

    ahb_slave_ram #(
        .ADDR_WIDTH      (ADDR_WIDTH),
        .DATA_WIDTH      (DATA_WIDTH),
        .MEM_DEPTH_BYTES (MEM_DEPTH_BYTES),
        .WAIT_THRESHOLD  (WAIT_THRESHOLD),
        .WAIT_CYCLES     (WAIT_CYCLES)
    ) u_ahb_slave_ram (
        .hclk_i       (hclk_i),
        .hresetn_i    (hresetn_i),

        .haddr_i      (haddr),
        .htrans_i     (htrans),
        .hburst_i     (hburst),
        .hsize_i      (hsize),
        .hwrite_i     (hwrite),
        .hprot_i      (hprot),
        .hmastlock_i  (hmastlock),
        .hwdata_i     (hwdata),

        .hreadyout_o  (hreadyout),
        .hresp_o      (hresp),
        .hrdata_o     (hrdata)
    );

endmodule