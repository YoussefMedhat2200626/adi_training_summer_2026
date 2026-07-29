`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2026 08:14:38 PM
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
    output reg [3:0] counter
);


always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
    end
    else begin
        counter <= counter + 1;
    end
end
    
endmodule
