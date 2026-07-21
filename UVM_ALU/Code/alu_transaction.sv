class alu_transaction;
    // Input Operands & Control Signals
    rand bit [7:0] A;
    rand bit [7:0] B;
    rand bit [2:0] opcode;

    // Output Signals
    bit       carryout;
    bit       zero_flag;
    bit [7:0] Result;

    function void display(string name = "TRANSACTION");
        $display("[%s] opcode=%03b | A=0x%0h (%0d), B=0x%0h (%0d) | Result=0x%0h, carryout=%0b, zero_flag=%0b",
                 name, opcode, A, A, B, B, Result, carryout, zero_flag);
    endfunction

    function alu_transaction copy();
        alu_transaction tr_copy = new();
        tr_copy.A         = this.A;
        tr_copy.B         = this.B;
        tr_copy.opcode    = this.opcode;
        tr_copy.carryout  = this.carryout;
        tr_copy.zero_flag = this.zero_flag;
        tr_copy.Result    = this.Result;
        return tr_copy;
    endfunction
endclass