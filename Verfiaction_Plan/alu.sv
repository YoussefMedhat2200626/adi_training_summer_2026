`timescale 1ns/1ps

module ALU #(parameter WIDTH = 4)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [1:0]       OP,
    input  wire             CLK,
    input  wire             RST,

    output                    Zero_Flag,
    output reg                Arithm_FLag,
    output reg                Logic_Flag,
    output reg                Carry_Flag,
    output reg [WIDTH-1:0]    Result
);

reg [WIDTH-1:0] Comp_Result;
reg Comp_Carry_Flag;
reg Comp_Arithm_Flag;
reg Comp_Logic_Flag;

assign Zero_Flag = (Result == 0);

always @(posedge CLK, negedge RST) begin
    if(!RST) begin
        Result          <= 'b0000;
        Carry_Flag      <= 1'b0;
        Arithm_FLag     <= 1'b0;
        Logic_Flag      <= 1'b0;
    end
    else begin
        Result         <= Comp_Result;
        Carry_Flag     <= Comp_Carry_Flag;
        Arithm_FLag    <= Comp_Arithm_Flag;
        Logic_Flag     <= Comp_Logic_Flag;
    end
end

always @(*) begin
    Comp_Result = 'b0000;
    case (OP)
        2'b00: begin
            {Comp_Carry_Flag,Comp_Result} = A + B;
            Comp_Arithm_Flag = 1'b1;
            Comp_Logic_Flag  = 1'b0;
        end
        2'b01: begin
            {Comp_Carry_Flag,Comp_Result} = A - B;
            Comp_Arithm_Flag = 1'b1;
            Comp_Logic_Flag  = 1'b0;
        end
        2'b10: begin
            {Comp_Carry_Flag,Comp_Result} = A & B;
            Comp_Arithm_Flag = 1'b0;
            Comp_Logic_Flag  = 1'b1;
        end
        2'b11: begin
            {Comp_Carry_Flag,Comp_Result} = A | B;
            Comp_Arithm_Flag = 1'b0;
            Comp_Logic_Flag  = 1'b1;
        end
    endcase
end

endmodule