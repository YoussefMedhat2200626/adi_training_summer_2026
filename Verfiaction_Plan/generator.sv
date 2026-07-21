class generator;
    mailbox #(alu_transaction) gen2drv;
    event gen_handover;
    event done;
    bit   is_done = 1'b0; 
    int num_random_txns = 200;
    int total_txns = 0;

    function new(mailbox #(alu_transaction) gen2drv, int num_random_txns = 200);
        this.gen2drv = gen2drv;
        this.num_random_txns = num_random_txns;
        this.total_txns = 24 + num_random_txns;
    endfunction

    task run_directed();
        alu_transaction t;
        bit [WIDTH-1:0] max = {WIDTH{1'b1}};
        bit [WIDTH-1:0] corners_a[$] = '{0, 0, max, max, max, 0};
        bit [WIDTH-1:0] corners_b[$] = '{0, max, 0, max, max, max};
        bit [1:0] ops[4] = '{OP_ADD, OP_SUB, OP_AND, OP_OR};

        $display("[GEN] Starting directed tests...");
        foreach (corners_a[i]) begin
            foreach (ops[j]) begin
                t = new();
                t.A = corners_a[i];
                t.B = corners_b[i];
                t.OP = ops[j];
                t.rst_n = 1;
                $display("[GEN] Directed: A=%0d B=%0d OP=%0s", t.A, t.B, t.op_name());
                gen2drv.put(t);
                @(gen_handover);
            end
        end
        $display("[GEN] Directed tests complete. Total directed: %0d", $size(corners_a) * $size(ops));
    endtask

    task run_random();
        alu_transaction t;
        $display("[GEN] Starting %0d random tests...", num_random_txns);
        repeat (num_random_txns) begin
            t = new();
            t.rst_n = 1;
            if (!t.randomize())
                $error("[GEN] randomize() failed");
            gen2drv.put(t);
            @(gen_handover);
        end
        $display("[GEN] Completed %0d random tests", num_random_txns);
    endtask

    task run();
        $display("[GEN] Generator started at time %0t", $time);
        run_directed();
        run_random();
        is_done = 1'b1;
        test_finished = 1;
        -> done;
        $display("[GEN] All transactions generated. Total: %0d transactions", total_txns);
    endtask
endclass