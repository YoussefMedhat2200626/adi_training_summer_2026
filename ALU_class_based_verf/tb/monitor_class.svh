class monitor_class;
    mailbox #(transaction_class) mon_mb = new(1);
    virtual alu_intf vif;
    transaction_class tr;

    int id = 0;

    function new (mailbox #(transaction_class) ag_mb, virtual alu_intf ag_vif);
        mon_mb = ag_mb;
        vif = ag_vif;
    endfunction

    task run_mon ();
        wait (vif.rst_n == 1);

        forever begin
            tr = new();
            @(negedge vif.clk);
            tr.A = vif.A;
            tr.B = vif.B;
            tr.opcode = vif.opcode;
            @(negedge vif.clk);
            tr.ALU_Out = vif.ALU_Out;
            mon_mb.put(tr);
            tr.print_transction(id, "monitor");
            id = id + 1;
        end
    endtask
endclass