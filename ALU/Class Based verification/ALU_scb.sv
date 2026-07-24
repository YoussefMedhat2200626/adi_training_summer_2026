`include "ALU_tr.sv"

class alu_scb;
    mailbox #(alu_trans) mon2scb;

    function new(mailbox #(alu_trans) mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task run();
        alu_trans trans;
        logic [8:0] exp_out_carry; // 9 bits to catch carry
        logic       exp_overflow;
        
        forever begin
            mon2scb.get(trans);
            
            // Expected Logic Calculation
            exp_overflow = 1'b0;
            case (trans.opcode)
                3'b000: begin // ADD
                    exp_out_carry = trans.a + trans.b;
                    exp_overflow = (~trans.a[7] & ~trans.b[7] & exp_out_carry[7]) | 
                                   (trans.a[7] & trans.b[7] & ~exp_out_carry[7]);
                end
                3'b001: begin // SUB
                    exp_out_carry = trans.a - trans.b;
                    exp_overflow = (~trans.a[7] & trans.b[7] & exp_out_carry[7]) | 
                                   (trans.a[7] & ~trans.b[7] & ~exp_out_carry[7]);
                end
                3'b010: exp_out_carry = {1'b0, trans.a & trans.b}; // AND
                3'b011: exp_out_carry = {1'b0, trans.a | trans.b}; // OR
                3'b100: exp_out_carry = {1'b0, trans.a ^ trans.b}; // XOR
                3'b101: exp_out_carry = {1'b0, ~trans.a};          // NOT
                3'b110: exp_out_carry = {1'b0, trans.a << trans.b[2:0]}; // SLL
                3'b111: exp_out_carry = {1'b0, trans.a >> trans.b[2:0]}; // SRL
                default: exp_out_carry = 9'b0;
            endcase

            // Checkers
            if (trans.out !== exp_out_carry[7:0]) begin
                $error("OUT mismatch. Exp: %0h, Act: %0h", exp_out_carry[7:0], trans.out);
                trans.display("SCB");
            end
            
            if (trans.zero !== (trans.out == 8'b0)) begin
                $error("ZERO mismatch. Exp: %0b, Act: %0b", (trans.out == 8'b0), trans.zero);
                trans.display("SCB");
            end
            
            if (trans.opcode == 3'b000 && trans.carry !== exp_out_carry[8]) begin
                $error("CARRY mismatch.");
                trans.display("SCB");
            end

            if ((trans.opcode == 3'b000 || trans.opcode == 3'b001) && trans.overflow !== exp_overflow) begin
                $error("OVERFLOW mismatch. Exp: %0b, Act: %0b", exp_overflow, trans.overflow);
                trans.display("SCB");
            end
        end
    endtask
endclass