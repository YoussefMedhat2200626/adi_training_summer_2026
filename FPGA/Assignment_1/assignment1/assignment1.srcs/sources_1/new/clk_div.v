`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2026 08:17:33 PM
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

module clk_div(
    input clk, rst_n,
    output clk_out_1hz,
    output clk_out_1Mhz
);

reg [22:0] mod_counter;
assign clk_out_1hz = mod_counter[22];
assign clk_out_1Mhz = mod_counter[2];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        mod_counter <= 0;
    end else begin
        mod_counter <= mod_counter + 1;
    end
end
    
endmodule
