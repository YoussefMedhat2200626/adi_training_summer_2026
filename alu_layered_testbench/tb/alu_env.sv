
class alu_env;

    // Components
    alu_generator  gen;
    alu_driver     drv;
    alu_monitor    mon;
    alu_scoreboard scb;

    // Mailboxes
    mailbox #(alu_transaction) gen2drv_mbx;
    mailbox #(alu_transaction) mon2scb_mbx;

    // Events
    event gen_done_ev;

    // Virtual interface
    virtual alu_if vif;

    // Constructor
    function new(virtual alu_if vif);
        this.vif = vif;

        // Instantiate Mailboxes
        gen2drv_mbx = new();
        mon2scb_mbx = new();

        // Instantiate Components
        gen = new(gen2drv_mbx, gen_done_ev);
        drv = new(vif, gen2drv_mbx);
        mon = new(vif, mon2scb_mbx);
        scb = new(mon2scb_mbx);
    endfunction

    // Pre-test initialization
    task pre_test();
        $display("[ENVIRONMENT] Initializing interface...");
        vif.A      <= 8'h00;
        vif.B      <= 8'h00;
        vif.alu_op <= 2'b00;
        // Wait for reset to finish (assumed active low reset in standard systems)
        @(posedge vif.rst_n);
        #10;
    endtask

    // Run actual test
    task test();
        $display("[ENVIRONMENT] Starting simulation...");
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any
    endtask

    // Post-test wrap up
    task post_test();
        // Wait for scoreboard to check all generated transactions
        wait(scb.num_txns_checked == gen.num_txns);
        
        // Wait a few clocks for the pipeline to empty
        repeat(5) @(posedge vif.clk);
        
        $display("[ENVIRONMENT] Test Finished. Reporting...");
        scb.report();
    endtask

    // Main run task
    task run();
        pre_test();
        test();
        post_test();
        $finish;
    endtask

endclass
