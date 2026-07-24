interface alu_if(input logic clk, input logic rst_n);
    logic [7:0] a;
    logic [7:0] b;
    logic [2:0] opcode;
    logic [7:0] out;
    logic       zero;
    logic       carry;
    logic       overflow;
endinterface