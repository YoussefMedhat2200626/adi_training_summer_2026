//generates transactions, sends to driver
class alu_generator;

    mailbox #(alu_transaction) gen2drv;
    int num_transactions;
    event done;

    function new(mailbox #(alu_transaction) gen2drv, int num_transactions);
        this.gen2drv = gen2drv;
        this.num_transactions = num_transactions;
    endfunction

    task run();
        alu_transaction tr;
        $display("[GEN] Starting generation of %0d transactions", num_transactions);
        for (int i = 0; i < num_transactions; i++) begin
            tr = new();
            if (!tr.randomize())
                $error("[GEN] randomize failed on transaction %0d", i);
            gen2drv.put(tr);
        end
        $display("[GEN] Done generating %0d transactions", num_transactions);
        -> done;
    endtask

endclass
