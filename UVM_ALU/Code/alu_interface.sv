interface alu_interface;
    logic [7:0] A;
    logic [7:0] B;
    logic [2:0] opcode;
    logic       carryout;
    logic       zero_flag;
    logic [7:0] Result;
endinterface