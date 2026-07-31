module alu (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] alu_fun,

    output reg  [7:0] alu_out
);

reg [7:0] alu_out_comb;

always @(posedge clk or negedge rst) begin
    if (!rst)
        alu_out <= 8'b0;
    else
        alu_out <= alu_out_comb;
end

always @(*) begin
    alu_out_comb = 8'b0;

    case (alu_fun)
        2'b00: alu_out_comb = a + b;
        2'b01: alu_out_comb = a - b;
        2'b10: alu_out_comb = a & b;
        2'b11: alu_out_comb = a | b;
        default: alu_out_comb = 8'b0;
    endcase
end

endmodule