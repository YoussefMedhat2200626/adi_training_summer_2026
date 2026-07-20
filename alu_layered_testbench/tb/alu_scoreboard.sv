
class alu_scoreboard;

    // Mailbox to receive transactions from the monitor
    mailbox #(alu_transaction) mon2scb_mbx;

    //------------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------------
    int num_txns_checked = 0;
    int num_errors       = 0;

    // Per-operation pass/fail counters
    int op_pass[4];   // [0]=ADD [1]=SUB [2]=AND [3]=XOR
    int op_fail[4];

    // Constructor
    function new(mailbox #(alu_transaction) mbx);
        this.mon2scb_mbx = mbx;
        foreach (op_pass[i]) op_pass[i] = 0;
        foreach (op_fail[i]) op_fail[i] = 0;
    endfunction

    //------------------------------------------------------------------
    // Run Task — waits forever for transactions from monitor
    //------------------------------------------------------------------
    task run();
        alu_transaction txn;

        // Print column header
        $display("\n[SCOREBOARD] Starting scoreboard...");
        $display("%-4s | %-6s | %-8s | %-8s | %-6s | %-6s | %-6s | %-6s | %-6s | %-6s | %s",
                 "#", "OP", "A", "B",
                 "ACT_RES", "EXP_RES",
                 "ACT_C", "EXP_C",
                 "ACT_Z", "EXP_Z",
                 "STATUS");
        $display("%s", {"─"*90});

        forever begin
            mon2scb_mbx.get(txn);
            check_txn(txn);
        end
    endtask

    //------------------------------------------------------------------
    // Reference Model + Checker
    //------------------------------------------------------------------
    function void check_txn(alu_transaction txn);
        logic [8:0] exp_full;
        logic [7:0] exp_result;
        logic       exp_carry;
        logic       exp_zero;
        string      op_name;
        string      status;

        // ── Reference Model ──────────────────────────────────────────
        case (txn.alu_op)
            2'b00: begin
                op_name  = "ADD";
                exp_full  = {1'b0, txn.A} + {1'b0, txn.B};
                exp_result = exp_full[7:0];
                exp_carry  = exp_full[8];
            end
            2'b01: begin
                op_name  = "SUB";
                exp_full  = {1'b0, txn.A} - {1'b0, txn.B};
                exp_result = exp_full[7:0];
                exp_carry  = (txn.A < txn.B) ? 1'b1 : 1'b0; // Borrow
            end
            2'b10: begin
                op_name  = "AND";
                exp_result = txn.A & txn.B;
                exp_carry  = 1'b0;
            end
            2'b11: begin
                op_name  = "XOR";
                exp_result = txn.A ^ txn.B;
                exp_carry  = 1'b0;
            end
            default: begin
                op_name  = "???";
                exp_result = 8'h00;
                exp_carry  = 1'b0;
            end
        endcase

        // Zero flag — always based on the computed result
        exp_zero = (exp_result == 8'h00) ? 1'b1 : 1'b0;

        // ── Compare ──────────────────────────────────────────────────
        if (txn.result   !== exp_result ||
            txn.carry_out !== exp_carry  ||
            txn.zero      !== exp_zero) begin

            status = "FAIL ✗";
            op_fail[txn.alu_op]++;
            num_errors++;

        end else begin
            status = "PASS ✓";
            op_pass[txn.alu_op]++;
        end

        // ── Print one table row ──────────────────────────────────────
        $display("%-40d | %-6s | 0x%02h     | 0x%02h     | 0x%02h   | 0x%02h   |  %0b     |  %0b     |  %0b     |  %0b     | %s",
                 num_txns_checked + 1, op_name,
                 txn.A, txn.B,
                 txn.result,  exp_result,
                 txn.carry_out, exp_carry,
                 txn.zero,    exp_zero,
                 status);

        // ── If failure: print detailed mismatch block ─────────────────
        if (status == "FAIL ✗") begin
            $display("  ┌─ MISMATCH DETAIL ─────────────────────────────────────┐");
            if (txn.result !== exp_result)
                $display("  │  result    : GOT=0x%02h  EXPECTED=0x%02h                  │",
                         txn.result, exp_result);
            if (txn.carry_out !== exp_carry)
                $display("  │  carry_out : GOT=%0b     EXPECTED=%0b                      │",
                         txn.carry_out, exp_carry);
            if (txn.zero !== exp_zero)
                $display("  │  zero      : GOT=%0b     EXPECTED=%0b                      │",
                         txn.zero, exp_zero);
            $display("  └───────────────────────────────────────────────────────┘");
        end

        num_txns_checked++;
    endfunction

    //------------------------------------------------------------------
    // Final Summary Report
    //------------------------------------------------------------------
    function void report();
        int total_pass = op_pass[0] + op_pass[1] + op_pass[2] + op_pass[3];
        int total_fail = op_fail[0] + op_fail[1] + op_fail[2] + op_fail[3];

        $display("\n");
        $display("╔══════════════════════════════════════════════════════╗");
        $display("║           SCOREBOARD FINAL REPORT                   ║");
        $display("╠══════════════════════════════════════════════════════╣");
        $display("║  Total Transactions Checked : %-4d                  ║", num_txns_checked);
        $display("║  Total PASS                 : %-4d                  ║", total_pass);
        $display("║  Total FAIL                 : %-4d                  ║", total_fail);
        $display("╠══════════════════════════════════════════════════════╣");
        $display("║  Per-Operation Breakdown:                            ║");
        $display("║  ┌──────────┬──────────┬──────────┐                 ║");
        $display("║  │ Operation│  PASS    │  FAIL    │                 ║");
        $display("║  ├──────────┼──────────┼──────────┤                 ║");
        $display("║  │   ADD    │  %-6d  │  %-6d  │                 ║", op_pass[0], op_fail[0]);
        $display("║  │   SUB    │  %-6d  │  %-6d  │                 ║", op_pass[1], op_fail[1]);
        $display("║  │   AND    │  %-6d  │  %-6d  │                 ║", op_pass[2], op_fail[2]);
        $display("║  │   XOR    │  %-6d  │  %-6d  │                 ║", op_pass[3], op_fail[3]);
        $display("║  └──────────┴──────────┴──────────┘                 ║");
        $display("╠══════════════════════════════════════════════════════╣");

        if (total_fail == 0)
            $display("║  RESULT:  ✅  ALL TESTS PASSED                       ║");
        else
            $display("║  RESULT:  ❌  TEST FAILED — %0d ERROR(S) FOUND        ║", total_fail);

        $display("╚══════════════════════════════════════════════════════╝\n");

        if (total_fail > 0)
            $fatal(1, "TEST FAILED WITH %0d ERRORS!", total_fail);
    endfunction

endclass
