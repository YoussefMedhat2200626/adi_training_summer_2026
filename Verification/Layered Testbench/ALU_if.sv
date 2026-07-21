import ALU_shared_pkg :: *;
interface ALU_if (input bit clk);
    bit rst_n;
    bit signed [WIDTH - 1:0]  A,B;
    opcode_e opcode;
    bit [WIDTH - 1:0] ALU_OUT;
    bit carry_flag, arith_flag, logic_flag, zero_flag;

    modport DUT (input clk,rst_n,A,B,opcode, output ALU_OUT, carry_flag,arith_flag,logic_flag,zero_flag);

endinterface