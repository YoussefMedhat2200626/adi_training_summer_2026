`timescale 1ns / 1ps

module spi_top (
    input  wire sclk,
    input  wire csb,
    input  wire sdi,
    output wire sdo
);

    wire [14:0] addr;
    wire [7:0]  wr_data;
    wire [7:0]  rd_data;
    wire        wr_en;

    spi_slave u_spi_slave (
        .sclk    (sclk),
        .csb     (csb),
        .sdi     (sdi),
        .sdo     (sdo),
        .wr_en   (wr_en),
        .addr    (addr),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

    register_map u_register_map (
        .clk     (sclk),    // SCLK acts as the memory clock
        .wr_en   (wr_en),
        .addr    (addr),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

endmodule