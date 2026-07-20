
class alu_transaction;

    //------------------------------------------------------------------
    // Stimulus Fields (Randomizable)
    //------------------------------------------------------------------
    rand logic [7:0] A;          // First operand
    rand logic [7:0] B;          // Second operand
    rand logic [1:0] alu_op;     // Operation selector

    //------------------------------------------------------------------
    // Response Fields (Observed from DUT)
    //------------------------------------------------------------------
    logic [7:0] result;          // ALU result
    logic       carry_out;       // Carry/Borrow flag
    logic       zero;            // Zero flag

    //------------------------------------------------------------------
    // Constraints (Layered Testbench Weights)
    //------------------------------------------------------------------
    constraint valid_op_c {
        alu_op inside {[0:3]};
    }

    // Advanced constraints for hitting corner cases naturally
    constraint corner_case_c {
        A dist {
            8'hFF := 10,  // 10% max value
            8'h00 := 10,  // 10% min value
            [8'h01:8'hFE] := 80 // 80% other
        };
        B dist {
            8'hFF := 10,
            8'h00 := 10,
            [8'h01:8'hFE] := 80
        };
    }

    // Force A == B sometimes to easily trigger zero flag in SUB/XOR
    constraint equal_c {
        (alu_op == 2'b01 || alu_op == 2'b11) -> (A == B) dist {
            1 := 10, // 10% of the time, force A == B
            0 := 90
        };
    }

    //------------------------------------------------------------------
    // Methods
    //------------------------------------------------------------------
    
    // Deep copy method
    function alu_transaction copy();
        alu_transaction copy_obj = new();
        copy_obj.A         = this.A;
        copy_obj.B         = this.B;
        copy_obj.alu_op    = this.alu_op;
        copy_obj.result    = this.result;
        copy_obj.carry_out = this.carry_out;
        copy_obj.zero      = this.zero;
        return copy_obj;
    endfunction

    // Print method
    function void print(string name = "alu_transaction");
        string op_name;
        case (alu_op)
            2'b00:   op_name = "ADD";
            2'b01:   op_name = "SUB";
            2'b10:   op_name = "AND";
            2'b11:   op_name = "XOR";
            default: op_name = "???";
        endcase
        $display("[%s] Op=%s A=0x%02h B=0x%02h | Result=0x%02h Carry=%0b Zero=%0b", 
                 name, op_name, A, B, result, carry_out, zero);
    endfunction

endclass
