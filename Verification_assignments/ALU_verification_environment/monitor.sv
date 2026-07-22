package monitor_pkg;
    import transaction_pkg::*;
    class monitor;
        virtual alu_if monitor_if;
        mailbox mon_mbox_u;
        mailbox mon_mbox_d;
        alu_item #(4) trn_mon;

        function new();
            mon_mbox_u = new();
            //mon_mbox_d = new();
        endfunction

        task run();
            @(posedge monitor_if.CLK);
            forever begin
                trn_mon = new();
                @(posedge monitor_if.CLK);
                #1

                trn_mon.RST   = monitor_if.RST;
                trn_mon.A     = monitor_if.A;
                trn_mon.B     = monitor_if.B;
                trn_mon.OpSel = monitor_if.OpSel;
                trn_mon.Out   = monitor_if.Out;
                trn_mon.Carry = monitor_if.Carry;

                mon_mbox_u.put(trn_mon);
                //mon_mbox_d.get(trn_mon);
            end
        endtask
    endclass
endpackage : monitor_pkg