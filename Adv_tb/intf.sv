interface intf();

    logic       clk    ;
    logic       rst_n  ;
    logic [3:0] A      ;
    logic [3:0] B      ;
    logic [1:0] opcode ;
    logic [3:0] result ;
    logic       carry  ;

endinterface
