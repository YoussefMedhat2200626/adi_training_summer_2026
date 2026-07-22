module alu (clk, rst, A, B, Cin, Opcode, Result, Carry, Borrow, Overflow);
  input clk;
  input rst;      
  input [3:0] A;        
  input [3:0] B;          
  input Cin;   
  input [1:0] Opcode;     
  output reg  [3:0] Result;     
  output reg  Carry;    
  output reg  Borrow;   
  output reg  Overflow; 
  
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      Result   <= 4'b0000;
      Carry    <= 1'b0;
      Borrow   <= 1'b0;
      Overflow <= 1'b0;
    end else begin
      Carry    <= 1'b0;
      Borrow   <= 1'b0;
      Overflow <= 1'b0;
      case (Opcode)
        2'b00: begin  
          {Carry, Result} <= A + B + Cin;
          Overflow <= (A[3] == B[3]) && (Result[3] != A[3]);
        end

        2'b01: begin 
          Result   <= A - B;
          Borrow   <= (A < B);
          Overflow <= (A[3] == B[3]) && (Result[3] != A[3]);
        end

        2'b10: begin  
          Result   <= A & B;
        end

        2'b11: begin  
          Result   <= A | B;
        end
      endcase
    end
  end
  initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, alu);
  end

endmodule