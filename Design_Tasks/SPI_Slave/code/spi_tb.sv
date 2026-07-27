`timescale 1ns/1ps

module tb_spi_slave_top;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 15;

reg rst_n;
reg SCLK;
reg CSB;
reg SDI;
wire SDO;

// Instantiate DUT
spi_slave_top #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH))
dut(.rst_n(rst_n),.SCLK(SCLK),.CSB(CSB),.SDI(SDI),.SDO(SDO));

// sclk generation
reg clk,clk_en;
initial begin
clk =0;clk_en=0;
forever begin
#5 clk=~clk;
end
end
assign SCLK = clk_en? clk:1'b0;

initial begin
//signals
rst_n = 0;
CSB= 1;
SDI= 0;
//reset
#20 rst_n = 1;
//select slave
#10 
CSB = 0;

//wait t_lead before starting clock
#10 clk_en=1;

//3 byte write operation

SDI=0; //write
@(posedge clk);
clk_en=1;

repeat (ADDR_WIDTH) begin
@(negedge clk);//data changes at the negative edge
SDI = 0; //zero address
end

//test burst by sending multiple bytes 
//byte1
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
SDI = $random; // random data
end
//byte2
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
SDI = $random; // random data
end
//byte3
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
SDI = $random; // random data
end

//stop clock after reading the last bit
@(negedge clk);
clk_en = 0;

//wait t_lag then deselect slave
#10 CSB = 1;

//select slave
#10 
CSB = 0;

//wait t_lead before starting clock
#10 clk_en=1;

//3 byte read operation

SDI=1; //read
@(posedge clk);
clk_en=1;

repeat (ADDR_WIDTH) begin
@(negedge clk);//data changes at the negative edge
SDI = 0; //zero address
end

//byte1
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
end
//byte2
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
end
//byte3
repeat (DATA_WIDTH) begin
@(negedge clk);//data changes at the negative edge
end

//stop clock after reading the last bit
@(negedge clk);
clk_en = 0;

//wait t_lag then deselect slave
#10 CSB = 1;
//stop
#50 $stop;
end
endmodule