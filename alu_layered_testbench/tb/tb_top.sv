`timescale 1ns/1ps

// Include all pure SV testbench files in order
`include "alu_transaction.sv"
`include "alu_generator.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_scoreboard.sv"
`include "alu_env.sv"
`include "alu_test.sv"

module tb_top;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Interface instance
    alu_if alu_vif(.clk(clk), .rst_n(rst_n));

    // DUT instance
    alu dut (
        .A(alu_vif.A),
        .B(alu_vif.B),
        .alu_op(alu_vif.alu_op),
        .result(alu_vif.result),
        .carry_out(alu_vif.carry_out),
        .zero(alu_vif.zero)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // Test execution
    initial begin
        alu_test test;
        int scenario_to_run;

        // Enable waveform dumping (VCD) for GTKWave or EDA Playground
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        // Optionally read scenario from command line argument (+SCENARIO=1)
        if (!$value$plusargs("SCENARIO=%d", scenario_to_run)) begin
            scenario_to_run = 0; // Default to full random
        end

        // Instantiate test class and pass virtual interface
        test = new(alu_vif);
        
        // Start the test
        test.run_test(scenario_to_run);
        
        $finish;
    end

endmodule
