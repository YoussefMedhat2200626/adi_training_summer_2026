class driver_class;
    mailbox #(transaction_class) driv_mb = new(1);
    virtual alu_intf vif;
    transaction_class tr;

    int id = 0;

    function new (mailbox #(transaction_class) ag_mb, virtual alu_intf ag_vif);
        driv_mb = ag_mb;
        vif = ag_vif;
    endfunction

    // task reset();
    //     vif.A      <= 0;
    //     vif.B      <= 0;
    //     vif.opcode <= 0;
    //     wait (vif.rst_n == 0);
    //     @(posedge vif.clk);
    //     wait (vif.rst_n == 1);
    //     $display("[DRIVER] Reset complete");
    // endtask

    task run_driv ();
        forever begin
            tr = new();
            driv_mb.get(tr);
            @(posedge vif.clk);
            tr.print_transction(id, "Driver");
            vif.A <= tr.A;
            vif.B <= tr.B;
            vif.opcode <= tr.opcode;
            id = id + 1;
        end

    endtask
endclass