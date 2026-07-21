class alu_scoreboard;
    mailbox #(alu_transaction) mon2scb;
    int pass_count = 0;
    int fail_count = 0;

    alu_transaction tr_cov;

    // Functional Coverage Group
    covergroup alu_cg;
        option.per_instance = 1;

        cov_opcode: coverpoint tr_cov.opcode {
            bins opcodes[] = {[3'b000 : 3'b111]};
        }

        cov_result: coverpoint tr_cov.Result {
            bins zero_val = {8'h00};
            bins max_val  = {8'hFF};
            bins auto_range[8] = {[8'h00 : 8'hFF]};
        }

        cov_carryout: coverpoint tr_cov.carryout {
            bins carry_set   = {1'b1};
            bins carry_clear = {1'b0};
        }

        cov_zero_flag: coverpoint tr_cov.zero_flag {
            bins zero_set   = {1'b1};
            bins zero_clear = {1'b0};
        }

        cov_op_x_zero: cross cov_opcode, cov_zero_flag;

        // Cross coverage ignoring unreachable hardware carry states for non-ADD/SUB opcodes
        cov_op_x_carry: cross cov_opcode, cov_carryout {
            ignore_bins no_carry = binsof(cov_opcode) intersect {3'b000, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111} 
                                  && binsof(cov_carryout) intersect {1'b1};
        }

        cov_A: coverpoint tr_cov.A {
            bins min_A = {8'h00};
            bins max_A = {8'hFF};
        }
        cov_B: coverpoint tr_cov.B {
            bins min_B = {8'h00};
            bins max_B = {8'hFF};
        }
    endgroup

    function new(mailbox #(alu_transaction) mon2scb);
        this.mon2scb = mon2scb;
        alu_cg       = new();
    endfunction

    task run();
        alu_transaction tr;
        bit [7:0] exp_result;
        bit       exp_carryout;
        bit       exp_zero_flag;

        forever begin
            mon2scb.get(tr);
            tr_cov = tr;
            alu_cg.sample();

            // Golden Reference Model
            exp_carryout = 1'b0;
            case (tr.opcode)
                3'b000: exp_result = tr.A;
                3'b001: {exp_carryout, exp_result} = tr.A + tr.B;
                3'b010: {exp_carryout, exp_result} = tr.A - tr.B;
                3'b011: exp_result = tr.A + 1'b1;
                3'b100: exp_result = tr.A - 1'b1;
                3'b101: exp_result = tr.A & tr.B;
                3'b110: exp_result = tr.A | tr.B;
                3'b111: exp_result = ~tr.A;
                default: exp_result = tr.A;
            endcase

            exp_zero_flag = (exp_result == 8'h00) ? 1'b1 : 1'b0;

            if (tr.Result === exp_result && tr.carryout === exp_carryout && tr.zero_flag === exp_zero_flag) begin
                pass_count++;
            end else begin
                fail_count++;
                $error("[SCOREBOARD MISMATCH] Opcode: 3'b%03b | A: 0x%0h, B: 0x%0h | DUT Result: 0x%0h (Exp: 0x%0h), DUT Carry: %0b (Exp: %0b), DUT Zero: %0b (Exp: %0b)",
                       tr.opcode, tr.A, tr.B, tr.Result, exp_result, tr.carryout, exp_carryout, tr.zero_flag, exp_zero_flag);
            end
        end
    endtask
endclass