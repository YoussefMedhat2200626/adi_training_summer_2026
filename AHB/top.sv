module ahb_top (

    input  logic        HCLK,
    input  logic        HRESETn,

    input  logic [6:0]  i_beats_num,
    input  logic [31:0] i_address,
    input  logic [31:0] i_data,
    input  logic        i_start,
    input  logic        i_write

);

///////////////////////////////////////////////////////////
// Master <-> Bus Signals
///////////////////////////////////////////////////////////

logic [31:0] HADDR;
logic [31:0] HWDATA;
logic [31:0] HRDATA;

logic [1:0]  HTRANS;
logic [2:0]  HSIZE;
logic [2:0]  HBURST;

logic        HWRITE;
logic        HREADY;
logic        HRESP;

///////////////////////////////////////////////////////////
// Decoder
///////////////////////////////////////////////////////////

logic HSEL0;
logic HSEL1;

///////////////////////////////////////////////////////////
// Slave Responses
///////////////////////////////////////////////////////////

logic [31:0] HRDATA0;
logic [31:0] HRDATA1;

logic HREADYOUT0;
logic HREADYOUT1;

logic HRESP0;
logic HRESP1;

///////////////////////////////////////////////////////////
// Master
///////////////////////////////////////////////////////////

ahb_master u_master (

    .hclk      (HCLK),
    .hresetn   (HRESETn),

    .hrdata    (HRDATA),
    .hready    (HREADY),
    .hresp     (HRESP),

    .i_start   (i_start),
    .i_write   (i_write),
    .i_address (i_address),
    .i_data    (i_data),
    .i_beats_num(i_beats_num),

    .haddr     (HADDR),
    .hwdata    (HWDATA),
    .htrans    (HTRANS),
    .hwrite    (HWRITE),
    .hsize     (HSIZE),
    .hburst    (HBURST)

);


ahb_decoder u_decoder (

    .HADDR(HADDR),

    .HSEL0(HSEL0),
    .HSEL1(HSEL1)

);


ahb_slave_mem #(

    .MEM_DEPTH(1024)

) u_slave0 (

    .HCLK(HCLK),
    .HRESETn(HRESETn),

    .HSEL(HSEL0),

    .HADDR(HADDR),
    .HTRANS(HTRANS),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HWDATA(HWDATA),

    .HREADY(HREADY),

    .HRDATA(HRDATA0),
    .HREADYOUT(HREADYOUT0),
    .HRESP(HRESP0)

);



ahb_slave_mem #(

    .MEM_DEPTH(1024)

) u_slave1 (

    .HCLK(HCLK),
    .HRESETn(HRESETn),

    .HSEL(HSEL1),

    .HADDR(HADDR),
    .HTRANS(HTRANS),
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),
    .HBURST(HBURST),
    .HWDATA(HWDATA),

    .HREADY(HREADY),

    .HRDATA(HRDATA1),
    .HREADYOUT(HREADYOUT1),
    .HRESP(HRESP1)

);



ahb_mux u_mux (

    

    .HSEL0(HSEL0),
    .HSEL1(HSEL1),

    .HRDATA0(HRDATA0),
    .HREADYOUT0(HREADYOUT0),
    .HRESP0(HRESP0),

    .HRDATA1(HRDATA1),
    .HREADYOUT1(HREADYOUT1),
    .HRESP1(HRESP1),

    .HRDATA(HRDATA),
    .HREADYOUT(HREADY),
    .HRESP(HRESP)

);

endmodule