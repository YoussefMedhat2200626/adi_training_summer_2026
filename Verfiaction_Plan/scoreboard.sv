class scoreboard;
    mailbox #(alu_transaction) mon2scb;
    int pass_cnt = 0;
    int fail_cnt = 0;

    function new(mailbox #(alu_transaction) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    function void predict(input bit [WIDTH-1:0] a, input bit [WIDTH-1:0] b, input bit [1:0] op,
                          output bit [WIDTH-1:0] result, output bit carry,
                          output bit arithm, output bit logic_f, output bit zero);
        bit [WIDTH:0] wide;
        case (op)
            OP_ADD: begin wide = a + b; result = wide[WIDTH-1:0]; carry = wide[WIDTH]; arithm = 1; logic_f = 0; end
            OP_SUB: begin wide = a - b; result = wide[WIDTH-1:0]; carry = wide[WIDTH]; arithm = 1; logic_f = 0; end
            OP_AND: begin result = a & b; carry = 0; arithm = 0; logic_f = 1; end
            OP_OR : begin result = a | b; carry = 0; arithm = 0; logic_f = 1; end
            default: begin result = '0; carry = 0; arithm = 0; logic_f = 0; end
        endcase
        zero = (result == 0);
    endfunction

    task run();
        alu_transaction t;
        bit [WIDTH-1:0] exp_result;
        bit exp_carry, exp_arithm, exp_logic, exp_zero;
        int total_checked = 0;

        forever begin
            mon2scb.get(t);
            total_checked++;
            predict(t.A, t.B, t.OP, exp_result, exp_carry, exp_arithm, exp_logic, exp_zero);

            if (exp_result === t.Result && exp_carry === t.Carry_Flag &&
                exp_arithm === t.Arithm_FLag && exp_logic === t.Logic_Flag &&
                exp_zero === t.Zero_Flag) begin
                pass_cnt++;
                correct_count++;
                if (pass_cnt % 50 == 0)
                    t.display("SCB-PASS");
            end else begin
                fail_cnt++;
                error_count++;
                t.display("SCB-FAIL(actual)");
                $display("           expected: Result=%0d Carry=%0b Arithm=%0b Logic=%0b Zero=%0b",
                         exp_result, exp_carry, exp_arithm, exp_logic, exp_zero);
            end
        end
    endtask

    function void report();
        $display("\n===================== SCOREBOARD REPORT =====================");
        $display(" PASS = %0d   FAIL = %0d   TOTAL = %0d", pass_cnt, fail_cnt, pass_cnt + fail_cnt);
        $display(" RESULT: %0s", (fail_cnt == 0) ? "*** TEST PASSED ***" : "*** TEST FAILED ***");
        $display("===============================================================\n");
    endfunction
endclass