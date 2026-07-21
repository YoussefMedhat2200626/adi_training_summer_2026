// alu_test.sv, top of the layered testbench hierarchy
class alu_test;

    alu_environment env;
    int num_transactions;

    function new(virtual alu_if vif, int num_transactions = 100);
        this.num_transactions = num_transactions;
        env = new(vif, num_transactions);
    endfunction

    task run();
        $display("[TEST] Starting test with %0d transactions", num_transactions);
        env.run();
        $display("[TEST] Test complete");
    endtask

endclass
