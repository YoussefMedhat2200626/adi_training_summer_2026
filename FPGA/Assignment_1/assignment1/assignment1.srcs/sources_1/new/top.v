`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/20/2026 08:18:07 PM
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


module top(

    input clk,

    input rst_n,

    output [3:0] counter

    );

    wire counter_clk;

    wire counter_rst;

    wire clk_div_out_1hz;
    
    wire clk_div_out_1Mhz;

    clk_div u_clk_div (

    .clk(counter_clk),

    .rst_n(rst_n),

    .clk_out_1hz(clk_div_out_1hz),
    
    .clk_out_1Mhz(clk_div_out_1Mhz)

    

    );

      clk_wiz_0 u_pll

     (

      // Clock out ports

      .clk_out1(counter_clk),     // output clk_out1

      // Status and control signals

      .resetn(rst_n), // input resetn

      .locked(counter_rst),       // output locked

     // Clock in ports

      .clk_in1(clk));      // input clk_in1

  // INST_TAG_END ------ End INSTANTIATION Template ---------

  

    counter u_counter (

        .clk(clk_div_out_1hz),

        .rst_n(counter_rst),

        .counter(counter)

    );

endmodule
