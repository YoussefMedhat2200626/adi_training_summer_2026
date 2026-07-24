`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 05:20:22 PM
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


module top #(
    parameter DIV_VALUE = 22'd3999999
)(
    input wire clk_100mhz, // 100 MHz clock from the physical board
    input wire rst,        // Active high reset
    output wire [2:0] leds // 3 LEDs for counter
);

    wire clk_8mhz;
    wire clk_1hz;
    wire locked;

    // 1. Instantiate the PLL (Clocking Wizard IP)
    // Takes the 100 MHz board clock and outputs a stable 8 MHz clock
    clk_wiz_0 pll_inst (
        .clk_in1(clk_100mhz),
        .reset(rst),
        .locked(locked),
        .clk_out1(clk_8mhz) 
    );

    // 2. Instantiate our custom clock divider
    // Takes the 8 MHz clock from the PLL and slows it down to 1 Hz
    clk_div #(
        .DIV_VALUE(DIV_VALUE)
    ) divider_inst (
        .clk_in(clk_8mhz),
        .rst(rst),
        .clk_out(clk_1hz)
    );

    // 3. Instantiate the 3-bit counter
    // Takes the 1 Hz clock and counts up on the 3 LEDs
    counter3bit counter_inst (
        .clk(clk_1hz),
        .rst(rst),
        .count(leds)
    );

endmodule