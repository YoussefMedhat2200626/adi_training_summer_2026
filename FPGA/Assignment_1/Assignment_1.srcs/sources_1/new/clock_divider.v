`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:26:01 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider (
    input clk,        
    input reset,
    output reg clk_1Hz
);

reg [22:0] count;  

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        count <= 0;
        clk_1Hz <= 0;
    end else begin
    //must be 4_000_000 but it is 10 for simulation
        if (count == 10 - 1) begin
            clk_1Hz <= ~clk_1Hz;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
end

endmodule