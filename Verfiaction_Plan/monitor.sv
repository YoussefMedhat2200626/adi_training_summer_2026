class monitor;
    virtual alu_if.MONITOR vif;
    mailbox #(alu_transaction) mon2scb;
    int transaction_count = 0;
    alu_transaction pending;

    function new(virtual alu_if.MONITOR vif, mailbox #(alu_transaction) mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
        this.pending = null;
    endfunction

    task run();
        bit first = 1'b1;

        forever begin
            @(vif.mon_cb);
            #1step;
            
            if (vif.mon_cb.RST === 1'b0) begin
                pending = null;
                first = 1'b1;
                continue;
            end

            if (!first && pending != null) begin
                pending.Result = vif.mon_cb.Result;
                pending.Zero_Flag = vif.mon_cb.Zero_Flag;
                pending.Carry_Flag = vif.mon_cb.Carry_Flag;
                pending.Arithm_FLag = vif.mon_cb.Arithm_FLag;
                pending.Logic_Flag = vif.mon_cb.Logic_Flag;
                
                transaction_count++;
                if (transaction_count % 50 == 0)
                    $display("[MON] Captured %0d transactions so far @ %0t", 
                             transaction_count, $time);
                mon2scb.put(pending);
            end

            pending = new();
            pending.rst_n = vif.mon_cb.RST;
            pending.A = vif.mon_cb.A;
            pending.B = vif.mon_cb.B;
            pending.OP = vif.mon_cb.OP;
            first = 1'b0;
        end
    endtask
endclass