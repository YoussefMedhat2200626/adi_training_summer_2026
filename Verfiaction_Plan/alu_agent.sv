//=====================================================================
// alu_agent
//
// Standard "agent" wrapper around the ALU driver/monitor pair, plus
// a functional coverage collector fed straight from the monitor.
// Kept OUTSIDE alu_pkg on purpose: alu_cvg_pkg imports alu_pkg, so
// anything that needs both (like this agent) must live in its own
// file/scope that imports both packages, to avoid a circular
// package dependency.
//=====================================================================
`timescale 1ns/1ps

import alu_pkg::*;
import alu_cvg_pkg::*;

class alu_agent;
    // Virtual interface handles (driver side / monitor side)
    virtual alu_if.DRIVER  drv_vif;
    virtual alu_if.MONITOR mon_vif;

    // Sub-components
    driver       drv;
    monitor      mon;
    alu_coverage cvg;

    // Boundary mailboxes
    mailbox #(alu_transaction) gen2drv;  // in:  generator -> agent (driver)
    mailbox #(alu_transaction) mon2scb;  // out: agent (monitor) -> scoreboard

    function new(virtual alu_if.DRIVER  drv_vif,
                 virtual alu_if.MONITOR mon_vif,
                 mailbox #(alu_transaction) gen2drv);
        this.drv_vif = drv_vif;
        this.mon_vif = mon_vif;
        this.gen2drv = gen2drv;

        mon2scb = new();
        cvg     = new();   // allocates its own cvg_mail

        drv = new(drv_vif, gen2drv);
        mon = new(mon_vif, mon2scb, cvg.cvg_mail);  // monitor fans out to scb + cvg
    endfunction

    task reset_dut();
        drv.reset_dut();
    endtask

    task run();
        fork
            drv.run();
            mon.run();
            cvg.run_coverage();
        join_none
    endtask

    function void report();
        cvg.report();
    endfunction
endclass
