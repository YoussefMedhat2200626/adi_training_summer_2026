class transaction #(parameter WIDTH = 4);

    rand bit               rst_n  ;
    rand bit [WIDTH-1:0]   A      ;
    rand bit [WIDTH-1:0]   B      ;
    rand bit [1:0]         opcode ;

    bit [WIDTH-1:0]        result ;
    bit                    carry  ;

    constraint c_legal_opcode { opcode inside {2'b00, 2'b01, 2'b10, 2'b11}; }

    function void display_transaction(input string name = "TRANSACTION");
        $display("************** This is the %s **************", name);
        $display(" rst_n = %0d | A = %0d (%0b) | B = %0d (%0b) | opcode = %0b | result = %0d | carry = %0d",
                   rst_n, A, A, B, B, opcode, result, carry);
        $display("*******************************************************");
    endfunction

endclass
