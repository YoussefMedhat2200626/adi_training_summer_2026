
interface alu_if #(
    parameter int N = 8
)(
    input logic clk,
    input logic rst_n
);

    //------------------------------------------------------------------
    // Signals
    //------------------------------------------------------------------
    logic [N-1:0] A;          // First operand
    logic [N-1:0] B;          // Second operand
    logic [1:0]   alu_op;     // Operation selector
    logic [N-1:0] result;     // ALU result
    logic         carry_out;  // Carry/Borrow flag
    logic         zero;       // Zero flag

endinterface
