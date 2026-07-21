`timescale 1ns/1ps

module alu_tb;

    `include "alu_transaction.sv"
    `include "alu_generator.sv"
    `include "alu_driver.sv"
    `include "alu_monitor.sv"
    `include "alu_agent.sv"
    `include "alu_scoreboard.sv"
    `include "alu_environment.sv"
    `include "alu_test.sv"

    localparam WIDTH = 8;

    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    alu_if #(.WIDTH(WIDTH)) vif (.clk(clk));

    alu #(.WIDTH(WIDTH)) dut (
        .clk        (clk),
        .rst        (vif.rst),
        .a          (vif.a),
        .b          (vif.b),
        .alu_fun    (vif.alu_fun),
        .alu_enable (vif.alu_enable),
        .alu_out    (vif.alu_out),
        .alu_valid  (vif.alu_valid)
    );

    alu_test test;

    initial begin
        test = new(vif, 100);  // 100 transactions
        test.run();
        $display("[TB] Simulation finished");
        $finish;
    end

    // Optional waveform dump
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule
