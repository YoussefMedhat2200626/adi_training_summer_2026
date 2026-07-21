//=====================================================================
// Package: alu_cvg_pkg
// Functional Coverage for ALU Verification
//=====================================================================
package alu_cvg_pkg;

import alu_pkg::*;

class alu_coverage;
    // Transaction handle for coverage sampling
    alu_transaction txn_cvg;
    
    // Mailbox to receive transactions from monitor
    mailbox #(alu_transaction) cvg_mail;
    
    // Coverage counters
    int total_samples = 0;
    int op_count[4] = '{0, 0, 0, 0};
    
    //-----------------------------------------------------------------
    // Functional Coverage Groups
    //-----------------------------------------------------------------
    
    // 1. OPCODE Coverage - Ensure all operations are tested
    covergroup opcode_cg @(cvg_mail.get(txn_cvg));
        // Opcode coverage - each opcode must be executed
        opcode_cp: coverpoint txn_cvg.OP {
            bins ADD = {OP_ADD};
            bins SUB = {OP_SUB};
            bins AND = {OP_AND};
            bins OR  = {OP_OR};
            bins INVALID = default;  // For invalid opcodes
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
            bins or_to_add  = (OP_OR => OP_ADD);
            bins or_to_sub  = (OP_OR => OP_SUB);
            bins or_to_and  = (OP_OR => OP_AND);
            bins same_op    = (OP_ADD => OP_ADD);
        }
    endgroup
    
    // 2. Input Value Coverage - Ensure all input ranges are tested
    covergroup input_cg @(cvg_mail.get(txn_cvg));
        // A value ranges
        A_cp: coverpoint txn_cvg.A {
            bins zero      = {0};
            bins max_pos   = {{WIDTH{1'b1}}};
            bins mid_low   = {[1:((1<<WIDTH)/4)]};
            bins mid_high  = {[((1<<WIDTH)/4)+1 : ((1<<WIDTH)*3/4)]};
            bins near_max  = {[((1<<WIDTH)*3/4)+1 : (1<<WIDTH)-2]};
            bins all_ones  = {{WIDTH{1'b1}}};
        }
        
        // B value ranges
        B_cp: coverpoint txn_cvg.B {
            bins zero      = {0};
            bins max_pos   = {{WIDTH{1'b1}}};
            bins mid_low   = {[1:((1<<WIDTH)/4)]};
            bins mid_high  = {[((1<<WIDTH)/4)+1 : ((1<<WIDTH)*3/4)]};
            bins near_max  = {[((1<<WIDTH)*3/4)+1 : (1<<WIDTH)-2]};
            bins all_ones  = {{WIDTH{1'b1}}};
        }
        
        // Walking ones for logical operations (AND/OR)
        A_walking_ones: coverpoint txn_cvg.A iff (txn_cvg.OP inside {OP_AND, OP_OR}) {
            bins ones[] = {1, 2, 4, 8, (1<<(WIDTH-1))};
            bins ones_comb[] = {3, 5, 6, 9, 10, 12};
            bins ones_all = {{WIDTH{1'b1}}};
        }
        
        // Cross coverage between A and B ranges
        A_B_cross: cross A_cp, B_cp {
            // Illegal bins - these combinations might not be meaningful
            illegal_bins zero_zero = binsof(A_cp.zero) && binsof(B_cp.zero);
        }
    endgroup
    
    // 3. Operation-Specific Coverage
    covergroup op_specific_cg @(cvg_mail.get(txn_cvg));
        // For ADD/SUB operations - check carry generation
        carry_gen: coverpoint txn_cvg.Carry_Flag iff (txn_cvg.OP inside {OP_ADD, OP_SUB}) {
            bins carry_0 = {0};
            bins carry_1 = {1};
        }
        
        // For ADD/SUB operations - check overflow conditions
        overflow_check: coverpoint (txn_cvg.A + txn_cvg.B) iff (txn_cvg.OP == OP_ADD) {
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
            bins zero    = {0};
            bins low     = {[1:3]};
            bins mid     = {[4:11]};
            bins high    = {[12:14]};
            bins all_ones = {{WIDTH{1'b1}}};
        }
        
        // Carry and zero flag combination
        carry_zero_cross: cross txn_cvg.Carry_Flag, txn_cvg.Zero_Flag {
            bins both_zero = binsof(txn_cvg.Carry_Flag) intersect {0} && 
                            binsof(txn_cvg.Zero_Flag) intersect {0};
            bins carry_only = binsof(txn_cvg.Carry_Flag) intersect {1} && 
                             binsof(txn_cvg.Zero_Flag) intersect {0};
            bins zero_only = binsof(txn_cvg.Carry_Flag) intersect {0} && 
                            binsof(txn_cvg.Zero_Flag) intersect {1};
            bins both_one = binsof(txn_cvg.Carry_Flag) intersect {1} && 
                           binsof(txn_cvg.Zero_Flag) intersect {1};
        }
    endgroup
    
    // 4. Corner Case Coverage
    covergroup corner_case_cg @(cvg_mail.get(txn_cvg));
        // Specific corner cases for each operation
        add_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_ADD) {
            bins zero_add     = {0, 0};
            bins max_add_1    = {{WIDTH{1'b1}}, 0};
            bins max_add_2    = {0, {WIDTH{1'b1}}};
            bins max_add_max  = {{WIDTH{1'b1}}, {WIDTH{1'b1}}};
            bins carry_add    = {15, 1};
        }
        
        sub_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_SUB) {
            bins zero_sub     = {0, 0};
            bins max_sub_0    = {{WIDTH{1'b1}}, 0};
            bins sub_equal    = {5, 5};
            bins sub_neg      = {0, 1};
            bins sub_borrow   = {0, 15};
        }
        
        and_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_AND) {
            bins zero_and     = {0, 0};
            bins max_and      = {{WIDTH{1'b1}}, {WIDTH{1'b1}}};
            bins and_all_zero = {0, 15};
            bins and_result   = {15, 10};
        }
        
        or_corners: coverpoint {txn_cvg.A, txn_cvg.B} iff (txn_cvg.OP == OP_OR) {
            bins zero_or      = {0, 0};
            bins max_or       = {{WIDTH{1'b1}}, {WIDTH{1'b1}}};
            bins or_all_one   = {15, 0};
        }
    endgroup
    
    // 5. Reset Behavior Coverage
    covergroup reset_cg @(cvg_mail.get(txn_cvg));
        reset_behavior: coverpoint txn_cvg.rst_n {
            bins reset_active   = {0};
            bins reset_inactive = {1};
        }
    endgroup
    
    //-----------------------------------------------------------------
    // Constructor
    //-----------------------------------------------------------------
    function new();
        cvg_mail = new();
        opcode_cg = new();
        input_cg = new();
        op_specific_cg = new();
        corner_case_cg = new();
        reset_cg = new();
    endfunction
    
    //-----------------------------------------------------------------
    // Coverage Sampling Task
    //-----------------------------------------------------------------
    task run_coverage();
        forever begin
            txn_cvg = new();
            cvg_mail.get(txn_cvg);
            
            // Update counters
            total_samples++;
            if (txn_cvg.OP inside {OP_ADD, OP_SUB, OP_AND, OP_OR}) begin
                op_count[txn_cvg.OP]++;
            end
            
            // Sample all coverage groups
            opcode_cg.sample();
            input_cg.sample();
            op_specific_cg.sample();
            corner_case_cg.sample();
            reset_cg.sample();
        end
    endtask
    
    //-----------------------------------------------------------------
    // Coverage Reporting
    //-----------------------------------------------------------------
    function void report();
        real overall_cvg;  // DECLARE ALL VARIABLES AT THE TOP!
        
        $display("\n===================== FUNCTIONAL COVERAGE REPORT =====================");
        $display("Total Transactions Sampled: %0d", total_samples);
        
        // Operation counts
        $display("\n--- Operation Distribution ---");
        if (total_samples > 0) begin
            $display("ADD: %0d (%.1f%%)", op_count[OP_ADD], (op_count[OP_ADD] * 100.0 / total_samples));
            $display("SUB: %0d (%.1f%%)", op_count[OP_SUB], (op_count[OP_SUB] * 100.0 / total_samples));
            $display("AND: %0d (%.1f%%)", op_count[OP_AND], (op_count[OP_AND] * 100.0 / total_samples));
            $display("OR : %0d (%.1f%%)", op_count[OP_OR], (op_count[OP_OR] * 100.0 / total_samples));
        end else begin
            $display("No transactions sampled!");
        end
        
        // Coverage group results
        $display("\n--- Coverage Group Results ---");
        $display("Opcode Coverage     : %0d%%", opcode_cg.get_coverage());
        $display("Input Coverage      : %0d%%", input_cg.get_coverage());
        $display("Op-Specific Coverage: %0d%%", op_specific_cg.get_coverage());
        $display("Corner Case Coverage: %0d%%", corner_case_cg.get_coverage());
        $display("Reset Coverage      : %0d%%", reset_cg.get_coverage());
        
        // Overall functional coverage
        overall_cvg = (opcode_cg.get_coverage() + input_cg.get_coverage() +
                       op_specific_cg.get_coverage() + corner_case_cg.get_coverage() +
                       reset_cg.get_coverage()) / 5.0;
        $display("\n--- Overall Functional Coverage: %.1f%% ---", overall_cvg);
        $display("==========================================================================\n");
    endfunction
    
endclass

endpackage