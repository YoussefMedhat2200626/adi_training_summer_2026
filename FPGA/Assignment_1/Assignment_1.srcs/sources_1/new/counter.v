`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:04:00 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input clk,
    input rst_n,
    
    output reg [2:0] counter
    );
    
always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            counter <= 3'b000;
        else
            counter <= counter + 1'b1;
    end

endmodule
