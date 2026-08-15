module spi_slave_wrapper (
    input  logic rst_n,   
    input  logic csb,     
    input  logic sclk,   
    input  logic sdi,    
    output logic sdo 
);

    logic [14:0] addr;
    logic        wr_en;
    logic [7:0]  wr_data;
    logic [7:0]  rd_data;

    spi_slave u_spi_slave (
        .rst_n   (rst_n),
        .csb     (csb),
        .sclk    (sclk),
        .sdi     (sdi),
        .sdo     (sdo),
        .addr    (addr),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

    register_map u_register_map (
        .clk     (sclk),
        .addr    (addr),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );

endmodule