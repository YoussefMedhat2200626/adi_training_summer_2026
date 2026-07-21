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
        this.total_txns = 24 + 4 + num_random_txns;  // 24 directed + 4 extra corners + random
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

    task run_extra_corners();
        // Specific (A, B, OP) combos that alu_cvg_pkg's corner_case_cg
        // bins target directly but that the pair-sweep in run_directed()
        // (and the weighted random distribution) don't reliably hit,
        // e.g. a carry out of a non-boundary ADD, or a specific SUB
        // equal/negative-result case. Driving them explicitly is what
        // takes corner_case_cg to 100% deterministically.
        alu_transaction t;
        bit [WIDTH-1:0] extra_a[$]  = '{15, 5, 0, 15};
        bit [WIDTH-1:0] extra_b[$]  = '{1,  5, 1, 10};
        bit [1:0]       extra_op[$] = '{OP_ADD, OP_SUB, OP_SUB, OP_AND};

        $display("[GEN] Starting extra corner-case tests...");
        foreach (extra_a[i]) begin
            t = new();
            t.A = extra_a[i];
            t.B = extra_b[i];
            t.OP = extra_op[i];
            t.rst_n = 1;
            $display("[GEN] Extra corner: A=%0d B=%0d OP=%0s", t.A, t.B, t.op_name());
            gen2drv.put(t);
            @(gen_handover);
        end
        $display("[GEN] Extra corner-case tests complete. Total: %0d", $size(extra_a));
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
        run_extra_corners();
        run_random();
        is_done = 1'b1;
        test_finished = 1;
        -> done;
        $display("[GEN] All transactions generated. Total: %0d transactions", total_txns);
    endtask
endclass