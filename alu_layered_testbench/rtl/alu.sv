
module alu #(
    parameter int N = 8    // Data width (default: 8 bits)
)(
    //------------------------------------------------------------------
    // Inputs
    //------------------------------------------------------------------
    input  logic [N-1:0] A,          // First operand
    input  logic [N-1:0] B,          // Second operand
    input  logic [1:0]   alu_op,     // Operation selector

    //------------------------------------------------------------------
    // Outputs
    //------------------------------------------------------------------
    output logic [N-1:0] result,     // ALU result
    output logic         carry_out,  // Carry/borrow flag (arithmetic only)
    output logic         zero        // Zero flag (result == 0)
);

    //------------------------------------------------------------------
    // Operation Encoding
    //------------------------------------------------------------------
    // alu_op[1:0] | Operation | Type
    // ------------|-----------|------------
    //   2'b00     | ADD       | Arithmetic
    //   2'b01     | SUB       | Arithmetic
    //   2'b10     | AND       | Logical
    //   2'b11     | XOR       | Logical
    //------------------------------------------------------------------

    //------------------------------------------------------------------
    // ALU Combinational Logic
    //------------------------------------------------------------------
    always_comb begin
        // Default assignments to prevent latch inference
        result    = '0;
        carry_out = 1'b0;

        case (alu_op)
            2'b00: begin
                // ADD — Arithmetic addition with carry out
                {carry_out, result} = A + B;
            end

            2'b01: begin
                // SUB — Arithmetic subtraction with borrow
                {carry_out, result} = A - B;
            end

            2'b10: begin
                // AND — Bitwise logical AND
                result    = A & B;
                carry_out = 1'b0;
            end

            2'b11: begin
                // XOR — Bitwise logical XOR
                result    = A ^ B;
                carry_out = 1'b0;
            end

            default: begin
                // Default case — outputs driven to zero
                result    = '0;
                carry_out = 1'b0;
            end
        endcase

        // Zero flag — asserted when result is all zeros
        zero = (result == '0);
    end

endmodule
