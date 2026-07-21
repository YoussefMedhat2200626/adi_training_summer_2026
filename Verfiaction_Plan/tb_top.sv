//=====================================================================
// tb_top: clock generation, DUT + interface instantiation, test launch
//=====================================================================
`timescale 1ns/1ps

import alu_pkg::*;

module tb_top;

    localparam WIDTH = alu_pkg::WIDTH;
    localparam CLK_PERIOD = 10;

    bit CLK;
    always #(CLK_PERIOD/2) CLK = ~CLK;

    alu_if #(.WIDTH(WIDTH)) vif (.CLK(CLK));

    ALU #(.WIDTH(WIDTH)) dut (
        .A           (vif.A),
        .B           (vif.B),
        .OP          (vif.OP),
        .CLK         (vif.CLK),
        .RST         (vif.RST),
        .Zero_Flag   (vif.Zero_Flag),
        .Arithm_FLag (vif.Arithm_FLag),
        .Logic_Flag  (vif.Logic_Flag),
        .Carry_Flag  (vif.Carry_Flag),
        .Result      (vif.Result)
    );

    wire [31:0] tb_error_count = alu_pkg::error_count;
    wire [31:0] tb_correct_count = alu_pkg::correct_count;
    wire tb_test_finished = alu_pkg::test_finished;

    initial begin
        test t;
        int  num_txns;

        if (!$value$plusargs("NUM_TXNS=%d", num_txns))
            num_txns = 1000;
        
        $display("[TB] Starting test with %0d transactions", num_txns);
        t = new(vif.DRIVER, vif.MONITOR, num_txns);
        t.run();
    end

    initial begin
        #5000000;
        $display("[TB] ERROR: watchdog timeout - simulation did not finish");
        $display("[TB] Total time: %0t", $time);
        $finish;
    end

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, tb_top);
    end

endmodule