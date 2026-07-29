module spi_wrapper #(
    parameter MEM_DEPTH   = 32768,
    parameter HEADER_SIZE = 16,
    parameter DATA_WIDTH  = 8
)(
    input  sclk,
    input  rst_n,
    input  SDI,
    input  csb,
    output SDO
);


    logic [HEADER_SIZE-2:0] addr;
    logic                   wn_en;

    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

 
    Single_port_Async_RAM #(
        .MEM_DEPTH (MEM_DEPTH),
        .ADDR_WIDTH(HEADER_SIZE-1),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_Single_port_Async_RAM (
        .sclk    (sclk),
        .rst_n   (rst_n),
        .addr    (addr),
        .wr_data (wr_data),
        .wr_en   (wn_en),
        .rd_data (rd_data)
    );


    spi_slave_interface #(
        .HEADER_SIZE(HEADER_SIZE),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_spi_slave_interface (
        .SDI     (SDI),
        .csb     (csb),
        .rd_data (rd_data),
        .sclk    (sclk),
        .rst_n   (rst_n),
        .addr    (addr),
        .SDO     (SDO),
        .wn_en   (wn_en),
        .wr_data (wr_data)
    );

endmodule