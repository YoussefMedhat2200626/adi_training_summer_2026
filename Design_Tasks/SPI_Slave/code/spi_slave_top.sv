module spi_slave_top #(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 15
)(
input  rst_n,SCLK,CSB,SDI,
output SDO
);
wire wr_en;
wire [DATA_WIDTH-1:0] wr_data;
wire [ADDR_WIDTH-1:0] addr;
wire [DATA_WIDTH-1:0] rd_data;

spi_slave #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
spi_inst (.rst_n(rst_n),.SCLK(SCLK),.CSB(CSB),.SDI(SDI),.SDO(SDO),
.rd_data(rd_data),.wr_en(wr_en),.wr_data(wr_data),.addr(addr));

register_map #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) 
register_map_inst (.clk(SCLK),.wr_en(wr_en),.addr(addr),.wr_data(wr_data),.rd_data(rd_data));

endmodule