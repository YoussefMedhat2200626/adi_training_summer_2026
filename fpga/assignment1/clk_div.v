`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:24:11 PM
// Design Name: 
// Module Name: clk_div
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


module clk_div #(
    parameter DIV_VALUE = 22'd3999999
)(
    input wire clk_in,  // 8 MHz clock input
    input wire rst,     // Active high reset
    output reg clk_out  // 1 Hz clock output
);

    reg [21:0] count;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            count <= 22'd0;
            clk_out <= 1'b0;
        end else begin
            if (count == DIV_VALUE) begin
                count <= 22'd0;
                clk_out <= ~clk_out; // Toggle the clock
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule