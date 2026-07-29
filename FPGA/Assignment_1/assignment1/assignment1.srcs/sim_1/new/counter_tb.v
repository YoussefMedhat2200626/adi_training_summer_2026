`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2026 08:19:19 PM
// Design Name: 
// Module Name: counter_tb
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


module counter_tb;

reg clk, rst_n;
wire [3:0] counter;

top uut (
.clk(clk),
.rst_n(rst_n),
.counter(counter)
);

initial clk = 0;
always #5 clk = ~clk;


initial begin
    rst_n = 0;
    repeat(2) @(negedge clk);
    rst_n = 1;
    
    #250000
    $stop;

end

endmodule
