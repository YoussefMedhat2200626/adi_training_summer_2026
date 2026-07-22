module alu #(parameter n = 4) (
    input  wire         CLK,
    input  wire         RST,
    input  wire [n-1:0] A,
    input  wire [n-1:0] B,
    input  wire [1:0]   OpSel,
    output reg  [n-1:0] Out,
    output reg          Carry
);

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;
    localparam OP_AND = 2'b10;
    localparam OP_OR  = 2'b11;

    always @(posedge CLK or negedge RST) begin

        if(!RST) begin
            Out = 4'h0;
            Carry = 1'b0;
        end else begin
            case (OpSel)
                OP_ADD: {Carry, Out} = A + B;
                OP_SUB: {Carry, Out} = A - B;
                OP_AND: {Carry, Out} = A & B;
                OP_OR:  {Carry, Out} = A | B;
                default: {Carry, Out} = 5'h0;
            endcase
        end

    end

endmodule
