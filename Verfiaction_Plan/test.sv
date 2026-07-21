//=====================================================================
// test
//
// Top-level test class: owns the generator, the ALU agent
// (driver + monitor + functional coverage) and the scoreboard, and
// sequences a run. Standalone file (not `include`d into alu_pkg) so
// that it can use both alu_pkg and alu_cvg_pkg without creating a
// circular package dependency.
//=====================================================================
`timescale 1ns/1ps

import alu_pkg::*;
import alu_cvg_pkg::*;

class test;
    generator  gen;
    alu_agent  agnt;
    scoreboard scb;

    mailbox #(alu_transaction) gen2drv;

    function new(virtual alu_if.DRIVER drv_vif, virtual alu_if.MONITOR mon_vif,
                 int num_random_txns = 200);
        gen2drv = new();

        gen  = new(gen2drv, num_random_txns);
        agnt = new(drv_vif, mon_vif, gen2drv);
        scb  = new(agnt.mon2scb);

        gen.gen_handover = agnt.drv.driver_handover;
    endfunction

    task run();
        agnt.reset_dut();

        fork
            agnt.run();
            scb.run();
        join_none

        gen.run();
        wait (gen.is_done);
        repeat (20) @(agnt.drv_vif.drv_cb);

        scb.report();
        agnt.report();

        $display("[TEST] Simulation complete at time %0t", $time);
        $display("[TEST] error_count=%0d correct_count=%0d", error_count, correct_count);
        $finish;
    endtask
endclass
