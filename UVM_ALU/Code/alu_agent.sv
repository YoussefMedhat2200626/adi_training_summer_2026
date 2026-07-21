class alu_agent;
    alu_generator gen;
    alu_driver    drv;
    alu_monitor   mon;

    mailbox #(alu_transaction) gen2drv;
    mailbox #(alu_transaction) mon2scb;
    event drv_done;
    event sample_ev;

    function new(virtual alu_interface vif, mailbox #(alu_transaction) mon2scb);
        this.gen2drv   = new();
        this.mon2scb   = mon2scb;
        
        gen = new(gen2drv, drv_done);
        drv = new(vif, gen2drv, drv_done, sample_ev);
        mon = new(vif, mon2scb, sample_ev);
    endfunction

    task run();
        fork
            drv.run();
            mon.run();
        join_none
    endtask
endclass