module ALU (alu_intf.DUT intf);

    always @ (posedge intf.clk or negedge intf.rst_n) begin
        if (~intf.rst_n) begin
            intf.ALU_Out <= 0 ;
        end
        else begin
            case (intf.opcode)
                2'b00: intf.ALU_Out <= intf.A + intf.B;        // Addition
                2'b01: intf.ALU_Out <= intf.A - intf.B;        // Subtraction
                2'b10: intf.ALU_Out <= intf.A & intf.B;        // AND
                2'b11: intf.ALU_Out <= intf.A | intf.B;        // OR
                default: intf.ALU_Out <= 5'b00000;    // Default case
            endcase
        end
    end

endmodule