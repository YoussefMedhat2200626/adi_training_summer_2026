module ALU(
    input clk, rst_n,
    input signed [7:0] A,B,
    input [1:0] opcode,
    output logic signed [7:0] ALU_OUT,
    output logic carry_flag, arith_flag, logic_flag, zero_flag
);

logic [7:0] ALU_OUT_comb;
logic carry_flag_comb, arith_flag_comb, logic_flag_comb;
assign arith_flag_comb = (opcode == 0 || opcode == 1);
assign logic_flag_comb = (opcode == 2 || opcode == 3);
always @* zero_flag = (ALU_OUT == 0);

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ALU_OUT <= 0;
        carry_flag <= 0;
        arith_flag <= 0;
        logic_flag <= 0;
    end else begin
        ALU_OUT <= ALU_OUT_comb;
        carry_flag <= carry_flag_comb;
        arith_flag <= arith_flag_comb;
        logic_flag <= logic_flag_comb;
    end
end

always @* begin
    carry_flag_comb = 0;
    case (opcode)
        0: {carry_flag_comb,ALU_OUT_comb} = A + B;
        1: {carry_flag_comb,ALU_OUT_comb} = A - B;
        2: ALU_OUT_comb = A & B;
        3: ALU_OUT_comb = A ^ B;
        default: {carry_flag_comb,ALU_OUT_comb} = 0;
    endcase
end

endmodule