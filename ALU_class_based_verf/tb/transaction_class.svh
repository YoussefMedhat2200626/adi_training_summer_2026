class transaction_class;
    // bit clk;
    // rand logic rst_n;
    rand logic [3 : 0] A, B;
    rand logic [1 : 0] opcode;
    logic [4 : 0] ALU_Out;

    // constraint c1 {rst_n dist {0 := 10, 1 := 90};}

    /*function new ();
        A = 0;
        B = 0;
        opcode = 0;
        rst_n = 0;
    endfunction*/

    function void print_transction (int id, string name);
        $display("------------------------- Transaction number : %0d from : %0p -------------------------", id, name);
        $display("%0t : A = %0b , B = %0b , opcode = %0b , ALU_Out = %0b", $realtime, A, B, opcode, ALU_Out);
    endfunction
endclass