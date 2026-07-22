`timescale 1ns/1ps

module top_tb;

    // Inputs
    reg clk;
    reg rst_n;

    // Outputsa
    wire [3:0] counter;

    // DUT
    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .counter(counter)
    );

    // Generate 100 MHz clock (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
    // Hold reset for a while
        #10;
    
        // Release reset
        rst_n = 1;
        // Apply reset
                #10;
        rst_n = 0;

        // Hold reset for a while
        #100;

        // Release reset
        rst_n = 1;

        // Run simulation
         #500000;   // 
     

        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t rst_n=%b counter=%h",
                 $time, rst_n, counter);
    end

endmodule