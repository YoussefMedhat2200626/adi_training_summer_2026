`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:21:13 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input clk,
    input rst_n,
    output [2:0] counter
);

wire clk_8MHz;
wire clk_1Hz;
wire locked;

//assign clk_8MHz = clk;
//assign locked = 1'b1;


clk_wiz_0 pll (
    .clk_in1(clk),
    .clk_out1(clk_8MHz),
    .resetn(rst_n),
    .locked(locked)
);


clock_divider div (
    .clk(clk_8MHz),
    .reset(locked),
    .clk_1Hz(clk_1Hz)
);


counter cnt (
    .clk(clk_1Hz),
    .rst_n(locked),
    .counter(counter)
);

endmodule