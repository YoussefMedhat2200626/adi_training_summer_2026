`include "ALU_tr.sv"

class alu_gen;
    mailbox #(alu_trans) gen2drv;
    int num_transactions;
    alu_trans trans;

    function new(mailbox #(alu_trans) gen2drv);
        this.gen2drv = gen2drv;
    endfunction

    task run();
        for (int i = 0; i < num_transactions; i++) begin
            trans = new();
            if (!trans.randomize()) $fatal("Gen: Randomization failed");
            gen2drv.put(trans);
        end
    endtask
endclass