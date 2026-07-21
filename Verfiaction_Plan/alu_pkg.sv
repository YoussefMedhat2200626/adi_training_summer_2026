`timescale 1ns/1ps
//=====================================================================
// Package: alu_pkg
// Class-based verification environment for the ALU DUT.
//=====================================================================
package alu_pkg;

    parameter int WIDTH   = 4;
    parameter int OP_ADD  = 2'b00;
    parameter int OP_SUB  = 2'b01;
    parameter int OP_AND  = 2'b10;
    parameter int OP_OR   = 2'b11;
    
    // Global variables for test monitoring
    static int error_count = 0;
    static int correct_count = 0;
    static bit test_finished = 0;

    //-----------------------------------------------------------------
    // Transaction
    //-----------------------------------------------------------------
    class alu_transaction;
        rand bit [WIDTH-1:0] A;
        rand bit [WIDTH-1:0] B;
        rand bit [1:0]       OP;
        bit                  rst_n;

        // corner-case weighting: mostly uniform random, with extra
        // weight on 0 and all-ones so corners get hit often
        constraint c_operands {
            A dist { 0 := 2, {WIDTH{1'b1}} := 2, [1:(1<<WIDTH)-2] :/ 6 };
            B dist { 0 := 2, {WIDTH{1'b1}} := 2, [1:(1<<WIDTH)-2] :/ 6 };
        }
        constraint c_op { OP inside {OP_ADD, OP_SUB, OP_AND, OP_OR}; }

        // filled in by monitor after the DUT produces its (delayed) result
        bit [WIDTH-1:0] Result;
        bit             Zero_Flag;
        bit             Arithm_FLag;
        bit             Logic_Flag;
        bit             Carry_Flag;

        function alu_transaction clone();
            clone = new();
            clone.A = A; 
            clone.B = B; 
            clone.OP = OP;
            clone.Result = Result;
            clone.Zero_Flag = Zero_Flag;
            clone.Arithm_FLag = Arithm_FLag;
            clone.Logic_Flag = Logic_Flag;
            clone.Carry_Flag = Carry_Flag;
            clone.rst_n = rst_n;
        endfunction

        function string op_name();
            case (OP)
                OP_ADD: return "ADD";
                OP_SUB: return "SUB";
                OP_AND: return "AND";
                OP_OR : return "OR";
                default: return "??";
            endcase
        endfunction

        function void display(string tag = "");
            $display("[%0s] A=%0d B=%0d OP=%0s Result=%0d Zero=%0b Carry=%0b Arithm=%0b Logic=%0b",
                       tag, A, B, op_name(), Result, Zero_Flag, Carry_Flag, Arithm_FLag, Logic_Flag);
        endfunction
    endclass

    //-----------------------------------------------------------------
    // Environment classes
    //-----------------------------------------------------------------
    `include "generator.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "scoreboard.sv"
    `include "test.sv"

endpackage