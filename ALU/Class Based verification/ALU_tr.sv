`ifndef ALU_TR
`define ALU_TR

class alu_trans;
    rand logic [7:0] a;
    rand logic [7:0] b;
    rand logic [2:0] opcode;
    
    // Outputs captured from DUT
    logic [7:0] out;
    logic       zero;
    logic       carry;
    logic       overflow;

    function void display(string name);
        $display("[%s] A=%0h B=%0h OP=%03b | OUT=%0h Z=%0b C=%0b V=%0b", 
                 name, a, b, opcode, out, zero, carry, overflow);
    endfunction
endclass

`endif