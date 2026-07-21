module alu #(parameter WIDTH = 8)(

    input  wire             clk, rst,
    input  wire [WIDTH-1:0] a, b,
    input  wire [1:0]       alu_fun,
    input  wire             alu_enable,
    output reg [WIDTH-1:0]  alu_out,
    output reg              alu_valid
);

reg [WIDTH-1:0] alu_out_comb;

always @ (posedge clk or negedge rst)
begin
    if (!rst)
        alu_out <= 'b0;
    else if (alu_enable)
        alu_out <= alu_out_comb;
end

always @ (*)
begin
    alu_valid = 0;
    alu_out_comb = 'b0;

    case (alu_fun)
    2'b00: begin alu_out_comb = a + b; alu_valid = 1; end // ADD
    2'b01: begin alu_out_comb = a - b; alu_valid = 1; end // SUB
    2'b10: begin alu_out_comb = a & b; alu_valid = 1; end // AND
    2'b11: begin alu_out_comb = a | b; alu_valid = 1; end // OR
    default: begin alu_out_comb = 'b0; alu_valid = 0; end
    endcase
end

endmodule
