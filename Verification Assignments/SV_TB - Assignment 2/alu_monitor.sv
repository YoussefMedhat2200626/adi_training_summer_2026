// alu_monitor.sv, observes the interface, sends to scoreboard
class alu_monitor;

    virtual alu_if vif;
    mailbox #(alu_transaction) mon2scb;
    int num_samples;

    function new(virtual alu_if vif, mailbox #(alu_transaction) mon2scb, int num_samples);
        this.vif = vif;
        this.mon2scb = mon2scb;
        this.num_samples = num_samples;
    endfunction

    task run();
        for (int i = 0; i < num_samples; i++) begin
            alu_transaction tr = new();
            @(vif.mon_cb);
            tr.rst = vif.mon_cb.rst;
            tr.a = vif.mon_cb.a;
            tr.b = vif.mon_cb.b;
            tr.alu_fun = alu_transaction::alu_fun_e'(vif.mon_cb.alu_fun);
            tr.alu_enable = vif.mon_cb.alu_enable;
            tr.alu_out = vif.mon_cb.alu_out;
            tr.alu_valid = vif.mon_cb.alu_valid;
            mon2scb.put(tr);
        end
        $display("[MON] Done monitoring %0d samples", num_samples);
    endtask

endclass
