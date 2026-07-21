//=====================================================================
// Package: alu_cvg_pkg
// Functional Coverage for ALU Verification
//
// Depends on alu_pkg (alu_transaction, WIDTH, OP_*). Kept as a
// separate package (rather than folded into alu_pkg) so that
// alu_pkg has no dependency back on this file -- alu_agent.sv and
// test.sv import both packages instead.
//=====================================================================
package alu_cvg_pkg;

import alu_pkg::*;

class alu_coverage;
    // Transaction handle for coverage sampling
    alu_transaction txn_cvg;

    // Mailbox fed by the monitor (or any tap point) with sampled txns
    mailbox #(alu_transaction) cvg_mail;

    // Coverage counters
    int total_samples = 0;
    int op_count[4] = '{0, 0, 0, 0};

    //-----------------------------------------------------------------
    // Functional Coverage Groups
    // NOTE: these covergroups have no sampling event of their own --
    // they are sampled explicitly via .sample() from run_coverage()
    // once per transaction pulled off cvg_mail. (A covergroup's
    // event-control cannot be a mailbox method call, only a genuine
    // SystemVerilog event/signal edge, so explicit sampling is used.)
    //-----------------------------------------------------------------

    // 1. OPCODE Coverage - Ensure all operations are tested
    covergroup opcode_cg;
        option.per_instance = 1;

        opcode_cp: coverpoint txn_cvg.OP {
            bins ADD     = {OP_ADD};
            bins SUB     = {OP_SUB};
            bins AND     = {OP_AND};
            bins OR      = {OP_OR};
        }

        // Transition coverage between opcodes
        opcode_trans: coverpoint txn_cvg.OP {
            bins add_to_sub = (OP_ADD => OP_SUB);
            bins add_to_and = (OP_ADD => OP_AND);
            bins add_to_or  = (OP_ADD => OP_OR);
            bins sub_to_add = (OP_SUB => OP_ADD);
            bins sub_to_and = (OP_SUB => OP_AND);
            bins sub_to_or  = (OP_SUB => OP_OR);
            bins and_to_add = (OP_AND => OP_ADD);
            bins and_to_sub = (OP_AND => OP_SUB);
            bins and_to_or  = (OP_AND => OP_OR);
            bins or_to_add  = (OP_OR  => OP_ADD);
            bins or_to_sub  = (OP_OR  => OP_SUB);
            bins or_to_and  = (OP_OR  => OP_AND);
            bins same_op    = (OP_ADD => OP_ADD), (OP_SUB => OP_SUB),
                               (OP_AND => OP_AND), (OP_OR  => OP_OR);
        }
    endgroup

    // 2. Input Value Coverage - Ensure all input ranges are tested
    covergroup input_cg;
        option.per_instance = 1;

        // A value ranges (WIDTH = 4 -> range 0..15)
        A_cp: coverpoint txn_cvg.A {
            bins zero      = {0};
            bins low       = {[1:4]};
            bins mid       = {[5:11]};
            bins high      = {[12:14]};
            bins all_ones  = {(1<<WIDTH)-1};
        }

        // B value ranges
        B_cp: coverpoint txn_cvg.B {
            bins zero      = {0};
            bins low       = {[1:4]};
            bins mid       = {[5:11]};
            bins high      = {[12:14]};
            bins all_ones  = {(1<<WIDTH)-1};
        }

        // Walking ones / bit-combinations for logical operations (AND/OR)
        A_walking_ones: coverpoint txn_cvg.A iff (txn_cvg.OP inside {OP_AND, OP_OR}) {
            bins single_bit[] = {1, 2, 4, 8};
            bins two_bits[]   = {3, 5, 6, 9, 10, 12};
            bins all_ones     = {(1<<WIDTH)-1};
        }

        // Cross coverage between A and B ranges
        A_B_cross: cross A_cp, B_cp {
            // A=0,B=0 is a legitimate (if trivial) stimulus - not excluded
        }
    endgroup

    // 3. Operation-Specific Coverage
    covergroup op_specific_cg;
        option.per_instance = 1;

        // For ADD/SUB operations - check carry generation
        carry_gen: coverpoint txn_cvg.Carry_Flag iff (txn_cvg.OP inside {OP_ADD, OP_SUB}) {
            bins carry_0 = {0};
            bins carry_1 = {1};
        }

        // For ADD - check overflow of the true (unwrapped) sum
        overflow_check: coverpoint (int'(txn_cvg.A) + int'(txn_cvg.B)) iff (txn_cvg.OP == OP_ADD) {
            bins no_overflow = {[0:15]};
            bins overflow    = {[16:30]};
        }

        // For AND/OR operations - check zero flag behavior
        zero_flag_logic: coverpoint txn_cvg.Zero_Flag iff (txn_cvg.OP inside {OP_AND, OP_OR}) {
            bins zero_false = {0};
            bins zero_true  = {1};
        }

        // Result value ranges
        result_cp: coverpoint txn_cvg.Result {
            bins zero     = {0};
            bins low      = {[1:3]};
            bins mid      = {[4:11]};
            bins high     = {[12:14]};
            bins all_ones = {(1<<WIDTH)-1};
        }

        // Plain (unconditional) flag coverpoints, used for the cross below
        carry_flag_cp: coverpoint txn_cvg.Carry_Flag;
        zero_flag_cp:  coverpoint txn_cvg.Zero_Flag;

        // Carry and zero flag combination
        carry_zero_cross: cross carry_flag_cp, zero_flag_cp;
    endgroup

    // 4. Corner Case Coverage
    covergroup corner_case_cg;
        option.per_instance = 1;

        add_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_ADD) {
            bins zero_add    = {{4'd0,  4'd0}};
            bins max_add_1   = {{4'd15, 4'd0}};
            bins max_add_2   = {{4'd0,  4'd15}};
            bins max_add_max = {{4'd15, 4'd15}};
            bins carry_add   = {{4'd15, 4'd1}};
        }

        sub_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_SUB) {
            bins zero_sub   = {{4'd0,  4'd0}};
            bins max_sub_0  = {{4'd15, 4'd0}};
            bins sub_equal  = {{4'd5,  4'd5}};
            bins sub_neg    = {{4'd0,  4'd1}};
            bins sub_borrow = {{4'd0,  4'd15}};
        }

        and_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_AND) {
            bins zero_and     = {{4'd0,  4'd0}};
            bins max_and      = {{4'd15, 4'd15}};
            bins and_all_zero = {{4'd0,  4'd15}};
            bins and_result   = {{4'd15, 4'd10}};
        }

        or_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_OR) {
            bins zero_or    = {{4'd0,  4'd0}};
            bins max_or     = {{4'd15, 4'd15}};
            bins or_all_one = {{4'd15, 4'd0}};
        }
    endgroup

    // 5. Reset Behavior Coverage
    covergroup reset_cg;
        option.per_instance = 1;

        reset_behavior: coverpoint txn_cvg.rst_n {
            bins reset_active   = {0};
            bins reset_inactive = {1};
        }
    endgroup

    //-----------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------
    function new();
        cvg_mail       = new();
        opcode_cg      = new();
        input_cg       = new();
        op_specific_cg = new();
        corner_case_cg = new();
        reset_cg       = new();
    endfunction

    //-----------------------------------------------------------------
    // Coverage Sampling Task - run in its own thread (fork/join_none)
    //-----------------------------------------------------------------
    task run_coverage();
        forever begin
            cvg_mail.get(txn_cvg);

            // reset_cg always samples -- this is what sees both the
            // rst_n=0 (reset-marker) and rst_n=1 (valid transaction)
            // values coming from the monitor.
            reset_cg.sample();

            // A reset marker has no meaningful A/B/OP/Result, so only
            // feed the transaction-content covergroups real (rst_n=1)
            // transactions.
            if (txn_cvg.rst_n) begin
                total_samples++;
                if (txn_cvg.OP inside {OP_ADD, OP_SUB, OP_AND, OP_OR}) begin
                    op_count[txn_cvg.OP]++;
                end

                opcode_cg.sample();
                input_cg.sample();
                op_specific_cg.sample();
                corner_case_cg.sample();
            end
        end
    endtask

    //-----------------------------------------------------------------
    // Coverage Reporting
    //-----------------------------------------------------------------
    function void report();
        real overall_cvg;

        $display("\n===================== FUNCTIONAL COVERAGE REPORT =====================");
        $display("Total Transactions Sampled: %0d", total_samples);

        // Operation counts
        $display("\n--- Operation Distribution ---");
        if (total_samples > 0) begin
            $display("ADD: %0d (%.1f%%)", op_count[OP_ADD], (op_count[OP_ADD] * 100.0 / total_samples));
            $display("SUB: %0d (%.1f%%)", op_count[OP_SUB], (op_count[OP_SUB] * 100.0 / total_samples));
            $display("AND: %0d (%.1f%%)", op_count[OP_AND], (op_count[OP_AND] * 100.0 / total_samples));
            $display("OR : %0d (%.1f%%)", op_count[OP_OR],  (op_count[OP_OR]  * 100.0 / total_samples));
        end else begin
            $display("No transactions sampled!");
        end

        // Coverage group results
        $display("\n--- Coverage Group Results ---");
        $display("Opcode Coverage     : %0.1f%%", opcode_cg.get_coverage());
        $display("Input Coverage      : %0.1f%%", input_cg.get_coverage());
        $display("Op-Specific Coverage: %0.1f%%", op_specific_cg.get_coverage());
        $display("Corner Case Coverage: %0.1f%%", corner_case_cg.get_coverage());
        $display("Reset Coverage      : %0.1f%%", reset_cg.get_coverage());

        // Overall functional coverage
        overall_cvg = (opcode_cg.get_coverage() + input_cg.get_coverage() +
                       op_specific_cg.get_coverage() + corner_case_cg.get_coverage() +
                       reset_cg.get_coverage()) / 5.0;
        $display("\n--- Overall Functional Coverage: %.1f%% ---", overall_cvg);
        $display("==========================================================================\n");
    endfunction

endclass

endpackage
