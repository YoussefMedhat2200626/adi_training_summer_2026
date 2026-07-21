//=====================================================================
// test
//
// Top-level test class: builds an alu_env and drives it through a
// full run, then reports and finishes. Kept deliberately thin -- all
// the generator/agent/scoreboard wiring and run sequencing lives in
// alu_env. Standalone file (not `include`d into alu_pkg), same reason
// as alu_env.sv / alu_agent.sv: needs alu_cvg_pkg, which itself
// imports alu_pkg, so importing both here avoids a circular package
// dependency.
//=====================================================================
`timescale 1ns/1ps

import alu_pkg::*;
import alu_cvg_pkg::*;

class test;
    alu_env env;

    function new(virtual alu_if.DRIVER drv_vif, virtual alu_if.MONITOR mon_vif,
                 int num_random_txns = 200);
        env = new(drv_vif, mon_vif, num_random_txns);
    endfunction

    task run();
        env.run();
        env.report();

        $display("[TEST] Simulation complete at time %0t", $time);
        $display("[TEST] error_count=%0d correct_count=%0d", error_count, correct_count);
        $finish;
    endtask
endclass
