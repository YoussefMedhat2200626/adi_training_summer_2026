package alu_driver_pkg;
    import transaction_pkg::*;

    class driver;
        virtual alu_if driver_if;
        mailbox drv_mbox;
        event drv_event;
        alu_item #(4) trn_drv;

        function new();
            drv_mbox = new();
        endfunction

        task run();
            forever begin
                trn_drv = new();
                drv_mbox.get(trn_drv);
                @(negedge driver_if.CLK);
                driver_if.RST   <= trn_drv.RST;
                driver_if.A     <= trn_drv.A;
                driver_if.B     <= trn_drv.B;
                driver_if.OpSel <= trn_drv.OpSel;
                -> drv_event;
            end
        endtask
    endclass

    endpackage : alu_driver_pkg