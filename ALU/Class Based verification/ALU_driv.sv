`include "ALU_tr.sv"

class alu_drv;
    virtual alu_if vif;
    alu_trans trans;
    mailbox #(alu_trans) gen2drv;

    function new(virtual alu_if vif, mailbox #(alu_trans) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
    endfunction

    task run();
        forever begin
            gen2drv.get(trans);
            @(posedge vif.clk);
            vif.a      <= trans.a;
            vif.b      <= trans.b;
            vif.opcode <= trans.opcode;
        end
    endtask
endclass