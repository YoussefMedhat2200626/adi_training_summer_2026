module AHB_wrapper (W_ADDR_S, W_WRITE_S, W_BURST_S, W_ENABLE_S, W_WDATA_S, W_HCLK, W_HRESETn, W_HRDATA);
    
    // address & data width
    parameter WIDTH = 32;

    input logic [WIDTH - 1 : 0] W_ADDR_S;
    input logic W_WRITE_S;
    input logic [2 : 0] W_BURST_S;
    input logic W_ENABLE_S;
    input logic [WIDTH - 1 : 0] W_WDATA_S;
    input logic W_HCLK;
    input logic W_HRESETn;

    output logic [WIDTH -1 : 0] W_HRDATA;

    // connection wires
    logic [WIDTH - 1 : 0] hrdata;
    logic hready;
    logic hresp;
    logic [WIDTH - 1 : 0] haddr;
    logic hwrite;
    logic [2 : 0] hsize;
    logic [2 : 0] hburst;
    logic [3 : 0] hprot;
    logic [1 : 0] htrans;
    logic hmastlock;
    logic [WIDTH - 1 : 0] hwdata;

    AHB_master master (
        .HCLK(W_HCLK),
        .HRESETn(W_HRESETn),
        .HRDATA(hrdata),
        .HREADY(hready),
        .HRESP(hresp),
        .WDATA_S(W_WDATA_S),
        .ADDR_S(W_ADDR_S),
        .WRITE_S(W_WRITE_S),
        .BURST_S(W_BURST_S),
        .ENABLE_S(W_ENABLE_S),
        .HADDR(haddr),
        .HBURST(hburst),
        .HMASTLOCK(hmastlock),
        .HPROT(hprot),
        .HSIZE(hsize),
        .HTRANS(htrans),
        .HWDATA(hwdata),
        .HWRITE(hwrite)
    );

    AHB_slave slave (
        .HSELx(W_ENABLE_S),
        .HADDR(haddr),
        .HWRITE(hwrite),
        .HSIZE(hsize),
        .HBURST(hburst),
        .HPROT(hprot),
        .HTRANS(htrans),
        .HMASTLOCK(hmastlock),
        .HWDATA(hwdata),
        .HRESETn(W_HRESETn),
        .HCLK(W_HCLK), 
        .HREADYOUT(hready),
        .HRESP(hresp),
        .HRDATA(hrdata)
    );

    assign W_HRDATA = hrdata;

endmodule