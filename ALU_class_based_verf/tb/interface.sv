interface alu_intf(clk, rst_n);
    input bit clk;
    input logic rst_n;
    logic [3 : 0] A;
    logic [3 : 0] B;
    logic [1 : 0] opcode;
    logic [4 : 0] ALU_Out;

    modport DUT (input A, B, opcode, clk, rst_n,
             output ALU_Out);
endinterface