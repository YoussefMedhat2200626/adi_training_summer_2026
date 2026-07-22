// alu_driver.sv, drives transactions onto the interface

class alu_driver;

    virtual alu_if vif;
    mailbox #(alu_transaction) gen2drv;
    int num_transactions;

    function new(virtual alu_if vif, mailbox #(alu_transaction) gen2drv, int num_transactions);
        this.vif              = vif;
        this.gen2drv           = gen2drv;
        this.num_transactions  = num_transactions;
    endfunction

    task reset_dut();
        vif.drv_cb.rst        <= 0;
        vif.drv_cb.a          <= '0;
        vif.drv_cb.b          <= '0;
        vif.drv_cb.alu_fun    <= '0;
        vif.drv_cb.alu_enable <= 0;
        repeat (3) @(vif.drv_cb);
        vif.drv_cb.rst <= 1;
        @(vif.drv_cb);
        $display("[DRV] Reset complete");
    endtask

    task run();
        alu_transaction tr;
        reset_dut();
        for (int i = 0; i < num_transactions; i++) begin
            gen2drv.get(tr);
            if (tr.rst == 0) begin
                vif.drv_cb.rst <= 0;
                @(vif.drv_cb);
                vif.drv_cb.rst <= 1;
            end else begin
                vif.drv_cb.rst        <= 1;
                vif.drv_cb.a          <= tr.a;
                vif.drv_cb.b          <= tr.b;
                vif.drv_cb.alu_fun    <= tr.alu_fun;
                vif.drv_cb.alu_enable <= tr.alu_enable;
                @(vif.drv_cb);
            end
        end
        $display("[DRV] Done driving %0d transactions", num_transactions);
    endtask

endclass
