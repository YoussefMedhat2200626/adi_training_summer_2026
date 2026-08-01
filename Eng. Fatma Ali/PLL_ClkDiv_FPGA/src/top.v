module top(
    input        clk,
    input        rst_n,
    output [2:0] counter
);

wire counter_clk;
wire PLL_out;
wire PLL_locked;

counter counter_dut (
    .clk(counter_clk),
    .rst_n(PLL_locked),
    .counter(counter));

clk_div lck_div_dut (
    .ref_clk(PLL_out), // 8 MHZ
    .rst_n(PLL_locked),
    .divided_clk(counter_clk));
    
clk_wiz_0 PLL
   (
    // Clock out ports
    .clk_out1(PLL_out),     // output clk_out1
    // Status and control signals
    .resetn(rst_n), // input resetn
    .locked(PLL_locked),       // output locked
   // Clock in ports
    .clk_in1(clk));      // input clk_in1
endmodule
