`ifndef ALU_IF_SV
`define ALU_IF_SV

interface alu_if (input logic clk);
  logic [7:0] A;
  logic [7:0] B;
  logic [2:0] opcode;
  logic [7:0] Result;
  logic       Zero;
  logic       Carry;
  logic       Overflow;
  logic       rst;
endinterface

`endif