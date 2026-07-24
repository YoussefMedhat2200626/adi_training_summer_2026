`timescale 1ns / 1ps

module tb_top();

    reg clk_100mhz;
    reg rst;
    wire [2:0] leds;

    // Instantiate the full top module with fast clock divider
    top #(
        .DIV_VALUE(22'd3) 
    ) uut (
        .clk_100mhz(clk_100mhz),
        .rst(rst),
        .leds(leds)
    );

    // 100 MHz clock generation (Period = 10 ns)
    always #5.0 clk_100mhz = ~clk_100mhz;

    initial begin
        clk_100mhz = 0;
        rst = 1; 
        
        // Hold reset longer to give PLL time to lock
        #3000;
        rst = 0;
        
        #50000;
        
        $finish;
    end

endmodule
