module alu (
    input  [3:0] a, b,  
    input  [1:0]  opcode,     
    output reg [3:0] result  
);
    always @(*) begin
        case (opcode)
            2'b00: result = a + b;   // add
            2'b01: result = a - b;   // sub
            2'b10: result = a & b;   //and
            2'b11: result = a ^ b;   // xor
            default: result = 4'b0;
        endcase
    end
endmodule