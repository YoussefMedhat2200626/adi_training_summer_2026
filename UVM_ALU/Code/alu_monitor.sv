class alu_monitor;
    virtual alu_interface vif;
    mailbox #(alu_transaction) mon2scb;
    event sample_ev;

    function new(virtual alu_interface vif, mailbox #(alu_transaction) mon2scb, event sample_ev);
        this.vif       = vif;
        this.mon2scb   = mon2scb;
        this.sample_ev = sample_ev;
    endfunction

    task run();
        alu_transaction tr;
        forever begin
            @(sample_ev); // Triggered reliably by driver on every driven transaction
            tr           = new();
            tr.A         = vif.A;
            tr.B         = vif.B;
            tr.opcode    = vif.opcode;
            tr.Result    = vif.Result;
            tr.carryout  = vif.carryout;
            tr.zero_flag = vif.zero_flag;
            mon2scb.put(tr);
        end
    endtask
endclass