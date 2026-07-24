`include "ALU_test.sv"

module tb_top;
    logic clk;
    logic rst_n;

    // Interface instance
    alu_if vif(clk, rst_n);

    // DUT instance
    alu #(.WIDTH(8)) dut (vif);

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Execution
    initial begin
        alu_test test;
        test = new(vif);

        // Reset Sequence
        rst_n = 0;
        vif.a = 0; vif.b = 0; vif.opcode = 0;
        #20 rst_n = 1;

        // Run Test
        test.run();
        
        #100;
        $display("Test Finished!");
        $stop;
    end
endmodule