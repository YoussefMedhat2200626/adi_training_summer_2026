`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "transaction.sv"

class scoreboard;
  mailbox #(transaction) mon2sb;
  int passed = 0;
  int failed = 0;

  function new(mailbox #(transaction) mon2sb);
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      transaction tr;
      mon2sb.get(tr);
      check_output(tr);
    end
  endtask

  function void check_output(transaction tr);
    bit [7:0] exp_Result;
    bit       exp_Carry;
    bit       exp_Overflow;
    bit       exp_Zero;
    bit [8:0] temp;

    case (tr.opcode)
      3'b000: begin // ADD
        temp         = {1'b0, tr.A} + {1'b0, tr.B};
        exp_Result   = temp[7:0];
        exp_Carry    = temp[8];
        exp_Overflow = (tr.A[7] == tr.B[7]) && (exp_Result[7] != tr.A[7]);
      end
      3'b001: begin // SUB
        temp         = {1'b0, tr.A} - {1'b0, tr.B};
        exp_Result   = temp[7:0];
        exp_Carry    = temp[8];
        exp_Overflow = (tr.A[7] != tr.B[7]) && (exp_Result[7] != tr.A[7]);
      end
      3'b010: exp_Result = tr.A & tr.B;       // AND
      3'b011: exp_Result = tr.A | tr.B;       // OR
      3'b100: exp_Result = tr.A << tr.B[2:0]; // SHL
      3'b101: exp_Result = tr.A >> tr.B[2:0]; // SHR
      default: exp_Result = 8'b0;
    endcase

    exp_Zero = (exp_Result == 8'b0);

    if (tr.Result === exp_Result && tr.Zero === exp_Zero &&
        tr.Carry === exp_Carry   && tr.Overflow === exp_Overflow) begin
      passed++;
      $display("[SCOREBOARD] PASS | A=%0d B=%0d Op=%0b -> Res=%0d", tr.A, tr.B, tr.opcode, tr.Result);
    end else begin
      failed++;
      $display("[SCOREBOARD] FAIL | A=%0d B=%0d Op=%0b -> Res=%0d (Exp:%0d)", tr.A, tr.B, tr.opcode, tr.Result, exp_Result);
    end
  endfunction

  function void report();
    $display("\n========================================");
    $display("          FINAL TEST REPORT             ");
    $display("========================================");
    $display("  PASSED: %0d", passed);
    $display("  FAILED: %0d", failed);
    $display("========================================\n");
  endfunction
endclass

`endif