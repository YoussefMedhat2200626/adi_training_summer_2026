class alu_scoreboard;

    mailbox #(alu_transaction) mon2scb;
    int num_samples;

    alu_transaction prev;
    bit             prev_valid;
    int unsigned    match_cnt, mismatch_cnt;

    function new(mailbox #(alu_transaction) mon2scb, int num_samples);
        this.mon2scb    = mon2scb;
        this.num_samples = num_samples;
    endfunction

    task run();
        for (int i = 0; i < num_samples; i++) begin
            alu_transaction tr;
            mon2scb.get(tr);
            check(tr);
        end
        report();
    endtask

    task check(alu_transaction tr);
        bit [8:0] exp_carry_sum;
        bit [7:0] exp_out;

        //Reset check
        if (tr.rst == 0) begin
            if (tr.alu_out == 0)
                $display("[SB] PASS: reset -> alu_out == 0");
            else begin
                mismatch_cnt++;
                $error("[SB] FAIL: reset asserted but alu_out=%0h != 0", tr.alu_out);
            end
            prev_valid = 0;
            return;
        end

        //alu_valid: combinational on THIS transaction's own alu_fun
        if (tr.alu_valid !== 1'b1) begin
            mismatch_cnt++;
            $error("[SB] FAIL: alu_valid expected 1, got 0 (fun=%s)", tr.alu_fun.name());
        end

        //alu_out: registered, predicted from PREVIOUS transaction ---
        if (!prev_valid) begin
            prev = tr.copy();
            prev_valid = 1;
            return;
        end

        if (prev.alu_enable) begin
            case (prev.alu_fun)
                alu_transaction::ADD: begin
                    exp_carry_sum = prev.a + prev.b;
                    exp_out       = exp_carry_sum[7:0];
                end
                alu_transaction::SUB: begin
                    exp_carry_sum = prev.a - prev.b;
                    exp_out       = exp_carry_sum[7:0];
                end
                alu_transaction::AND_OP: exp_out = prev.a & prev.b;
                alu_transaction::OR_OP:  exp_out = prev.a | prev.b;
            endcase

            if (tr.alu_out == exp_out) begin
                match_cnt++;
                $display("[SB] PASS: %s", tr.convert2string());
            end else begin
                mismatch_cnt++;
                $error("[SB] FAIL: fun=%s a=%0h b=%0h => exp_out=%0h | got_out=%0h",
                       prev.alu_fun.name(), prev.a, prev.b, exp_out, tr.alu_out);
            end
        end

        prev = tr.copy();
    endtask

    function void report();
        $display("=====================================================");
        $display("[SB] Scoreboard summary: matches=%0d mismatches=%0d", match_cnt, mismatch_cnt);
        $display("=====================================================");
    endfunction

endclass
