module top
(
    input clk,
    input rst_n,
    //input divisor,
    output[2:0] counter
);

wire clk_counter;
wire lock_counter;
wire clk_out;

clk_wiz_0 u_pll
(
    // Clock out ports
    .clk_out1(clk_counter),        // output clk_out1
    // Status and control signals
    .resetn(rst_n), // input resetn
    .locked(lock_counter),         // output locked
    // Clock in ports
    .clk_in1(clk)                  // input clk_in1
);
clock_div u_clock_div (clk_counter,rst_n,524288,clk_out);//F/(divsor*2) 

counter u_count(
    .clk(clk_out),
    .rst_n(lock_counter),
    .counter(counter)
);

endmodule