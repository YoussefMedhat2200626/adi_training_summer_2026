`timescale 1ns/1ps

class test;
    generator  gen;
    driver     drv;
    monitor    mon;
    scoreboard scb;

    mailbox #(alu_transaction) gen2drv;
    mailbox #(alu_transaction) mon2scb;

    function new(virtual alu_if.DRIVER drv_vif, virtual alu_if.MONITOR mon_vif,
                 int num_random_txns = 200);
        gen2drv = new();
        mon2scb = new();

        gen = new(gen2drv, num_random_txns);
        drv = new(drv_vif, gen2drv);
        mon = new(mon_vif, mon2scb);
        scb = new(mon2scb);
        
        gen.gen_handover = drv.driver_handover;
    endfunction

    task run();
        drv.reset_dut();

        fork
            drv.run();
            mon.run();
            scb.run();
        join_none

        gen.run();
        wait (gen.is_done);
        repeat (20) @(drv.vif.drv_cb);

        scb.report();
        
        $display("[TEST] Simulation complete at time %0t", $time);
        $display("[TEST] error_count=%0d correct_count=%0d", error_count, correct_count);
        $finish;
    endtask
endclass