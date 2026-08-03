`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/03/2026 01:31:37 PM
// Design Name: 
// Module Name: counter_tb
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


`timescale 1ns/1ps

module counter_tb;

    reg clk;
    reg rst_n;
    wire [2:0] counter;   

    top dut (
        .clk(clk),
        .rst_n(rst_n),
        .counter(counter)
    );

    
    initial clk = 0;
    always #5 clk = ~clk;
    
    //for simulation only
    initial begin
         force dut.locked = 0;
         force dut.clk_8MHz = clk;
     end
    initial begin
        $display("Time\tRST_N\tCounter");
        $monitor("%0t\t%b\t%d", $time, rst_n, counter);

        
        rst_n = 0;
        #20;
        
        force dut.locked = 1;
        rst_n = 1;

       
        #300000;

        $display("Simulation finished at time %0t", $time);
        $finish;
    end

   
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);
    end
    
 

endmodule