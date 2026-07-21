class driver;
    virtual alu_if.DRIVER vif;
    mailbox #(alu_transaction) gen2drv;
    event driver_handover;
    int transaction_count = 0;
    bit first_txn = 1;

    function new(virtual alu_if.DRIVER vif, mailbox #(alu_transaction) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task reset_dut();
        vif.drv_cb.RST <= 1'b0;
        vif.drv_cb.A <= '0;
        vif.drv_cb.B <= '0;
        vif.drv_cb.OP <= '0;
        repeat (3) @(vif.drv_cb);
        vif.drv_cb.RST <= 1'b1;
        @(vif.drv_cb);
        $display("[DRV] reset complete @ %0t", $time);
    endtask

    task run();
        alu_transaction t;
        forever begin
            t = new();
            gen2drv.get(t);
            -> driver_handover;
            if (!first_txn) @(negedge vif.drv_cb);
            first_txn = 0;
            transaction_count++;
            if (transaction_count % 50 == 0)
                $display("[DRV] Sent %0d transactions so far @ %0t", 
                         transaction_count, $time);
            vif.drv_cb.RST <= t.rst_n;
            vif.drv_cb.A <= t.A;
            vif.drv_cb.B <= t.B;
            vif.drv_cb.OP <= t.OP;
            @(vif.drv_cb);
        end
    endtask
endclass