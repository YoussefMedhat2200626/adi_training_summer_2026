`ifndef TRANSACTION_SV
`define TRANSACTION_SV

// transaction: single stimulus/response packet for the ALU
class transaction;
  rand bit [7:0] A;
  rand bit [7:0] B;
  rand bit [2:0] opcode;

  // DUT response fields, filled in by the monitor
  bit [7:0] Result;
  bit       Zero;
  bit       Carry;
  bit       Overflow;

  function transaction copy();
    copy          = new();
    copy.A        = this.A;
    copy.B        = this.B;
    copy.opcode   = this.opcode;
    copy.Result   = this.Result;
    copy.Zero     = this.Zero;
    copy.Carry    = this.Carry;
    copy.Overflow = this.Overflow;
    return copy;
  endfunction

  function void display(string tag);
    $display("[%0s] A=%0d B=%0d opcode=%03b | Result=%0d Zero=%0b Carry=%0b Overflow=%0b",
             tag, A, B, opcode, Result, Zero, Carry, Overflow);
  endfunction
endclass

`endif