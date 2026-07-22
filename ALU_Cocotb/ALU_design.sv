module ALU (clk, rst_n, A, B, opcode, ALU_Out);
    input logic clk;
    input logic rst_n;
    input logic [3:0] A;         
    input logic [3:0] B;        
    input logic [1:0] opcode;   
    output logic [3:0] ALU_Out;

    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            ALU_Out <= 0 ;
        end
        else begin
            case (opcode)
                2'b00: ALU_Out <= A + B;        // Addition
                2'b01: ALU_Out <= A - B;        // Subtraction
                2'b10: ALU_Out <= A & B;        // AND
                2'b11: ALU_Out <= A | B;        // OR
                default: ALU_Out <= 4'b00000000;    // Default case
            endcase
        end
    end

endmodule