//=====================================================================
// alu_env
//
// Environment layer sitting between the test and the agent:
// interface -> alu_agent (driver/monitor/coverage) -> alu_env -> test.
//
// Owns the generator, the alu_agent, and the scoreboard, wires them
// together, and knows how to run a full test sequence (reset, drive
// stimulus, drain, report). test.sv should just construct an env and
// call run()/report() on it.
//
// Standalone file (not `include`d into alu_pkg), same reasoning as
// alu_agent.sv / test.sv: it needs alu_agent, which itself depends on
// alu_cvg_pkg, so it imports both packages explicitly rather than
// living inside alu_pkg.
//=====================================================================
`timescale 1ns/1ps

import alu_pkg::*;
import alu_cvg_pkg::*;

class alu_env;
    generator  gen;
    alu_agent  agnt;
    scoreboard scb;

    mailbox #(alu_transaction) gen2drv;

    function new(virtual alu_if.DRIVER  drv_vif,
                 virtual alu_if.MONITOR mon_vif,
                 int num_random_txns = 200);
        gen2drv = new();

        gen  = new(gen2drv, num_random_txns);
        agnt = new(drv_vif, mon_vif, gen2drv);
        scb  = new(agnt.mon2scb);

        gen.gen_handover = agnt.drv.driver_handover;
    endfunction

    task run();
        // Bring up the agent (driver + monitor + coverage) and the
        // scoreboard first so the monitor is already alive to observe
        // reset -- this matters for reset_cg in functional coverage.
        fork
            agnt.run();
            scb.run();
        join_none

        agnt.reset_dut();

        gen.run();
        wait (gen.is_done);
        repeat (20) @(agnt.drv_vif.drv_cb);   // drain in-flight transactions
    endtask

    function void report();
        scb.report();
        agnt.report();
    endfunction
endclass
