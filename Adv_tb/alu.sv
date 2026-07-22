module alu (
    input  logic       clk,
    input  logic       rst_n,

    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic [1:0] opcode,

    output logic [3:0] result,
    output logic       carry
);

always_ff @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        result <= 4'd0;
        carry  <= 1'b0;
    end
    else begin

        case(opcode)

            2'b00: begin
                {carry,result} <= A + B;
            end

            2'b01: begin
                result <= A - B;
                carry  <= (A < B);
            end

            2'b10: begin
                result <= A & B;
                carry  <= 0;
            end

            2'b11: begin
                result <= A ^ B;
                carry  <= 0;
            end

        endcase

    end

end

endmodule
