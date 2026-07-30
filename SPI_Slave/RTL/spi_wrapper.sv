module spi_wrapper (csb, sclk, sdi, sdo);
    parameter int ADDR_WIDTH = 15;
    parameter int DATA_WIDTH = 8;

    input logic csb;
    input logic sclk;
    input logic sdi;
    output logic sdo;

    logic [ADDR_WIDTH-1:0] addr;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

    logic sdo_val;
    logic sdo_en;

    spi_slave spi (
        .CSB(csb),
        .SCLK(sclk),
        .SDI(sdi),
        .SDO(sdo_val),
        .SDO_en(sdo_en),
        .addr(addr),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    reg_map ram (
        .clk(sclk),
        .wr_en(wr_en),
        .addr(addr),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    assign sdo = (sdo_en) ? sdo_val : 1'bz;

endmodule