module AHB_slave (HSELx, HADDR, HWRITE, HSIZE, HBURST, HPROT, HTRANS, HMASTLOCK, HWDATA, HRESETn, HCLK, 
                 HREADYOUT, HRESP, HRDATA);

    // address & data width
    parameter WIDTH = 32;

    // RAM width & dipth
    parameter MEM_DIPTH = 256;
    parameter MEM_WIDTH = 32;

    // standard inputs
    input logic HSELx;
    input logic [WIDTH - 1 : 0] HADDR;
    input logic HWRITE;
    input logic [2 : 0] HSIZE;
    input logic [2 : 0] HBURST;
    input logic [3 : 0] HPROT;
    input logic [1 : 0] HTRANS;
    input logic HMASTLOCK;
    input logic [WIDTH - 1 : 0] HWDATA;
    input logic HRESETn;
    input logic HCLK;

    // standard outputs
    output logic HREADYOUT;
    output logic HRESP;
    output logic [WIDTH - 1 : 0] HRDATA;

    reg [MEM_WIDTH - 1 : 0] mem [MEM_DIPTH - 1 : 0];

    always @ (posedge HCLK) begin
        if (!HRESETn) begin
            HRDATA <= 32'b0;
        end
        else begin
            if (HSELx) begin
                if (HWRITE) begin
                    mem[HADDR] <= HWDATA;
                end
                else begin
                    HRDATA <= mem[HADDR];
                end
            end
        end
    end

    assign HREADYOUT = (HSELx) ? 1'b1 : 1'b0;
    assign HRESP = 1'b0;
    
endmodule