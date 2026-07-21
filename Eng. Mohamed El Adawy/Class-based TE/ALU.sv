module simple_alu (
    input  wire [7:0]   A,
    input  wire [7:0]   B,
    input  wire [2:0]   opcode,
    output reg  [7:0]   Result,
    output reg           Zero,
    output reg           Carry,
    output reg           Overflow
);
 
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_SHL = 3'b100;
    localparam OP_SHR = 3'b101;
 
    // Temporary 9-bit accumulator used inside the always block to
    // capture carry-out (ADD) / borrow (SUB) in bit 8
    reg [8:0] temp;
 
    always @(*) begin
        Result   = 8'b0;
        Carry    = 1'b0;
        Overflow = 1'b0;
        temp     = 9'b0;
 
        case (opcode)
            OP_ADD: begin
                temp     = {1'b0, A} + {1'b0, B};
                Result   = temp[7:0];
                Carry    = temp[8];
                Overflow = (A[7] == B[7]) && (temp[7] != A[7]);
            end
            OP_SUB: begin
                temp     = {1'b0, A} - {1'b0, B};
                Result   = temp[7:0];
                Carry    = temp[8];
                Overflow = (A[7] != B[7]) && (temp[7] != A[7]);
            end
            OP_AND: Result = A & B;
            OP_OR : Result = A | B;
            OP_SHL: Result = A << B[2:0];
            OP_SHR: Result = A >> B[2:0];
            default: Result = 8'b0;   // 3'b110 / 3'b111 -> invalid opcode
        endcase
 
        Zero = (Result == 8'b0);
    end
 
endmodule