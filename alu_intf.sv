interface alu_intf(input logic clk);
  logic rst;
  logic [3:0] A;
  logic [3:0] B;
  logic Cin;
  logic [1:0] Opcode;
  logic [3:0] Result;
  logic Carry;
  logic Borrow;
  logic Overflow;
endinterface