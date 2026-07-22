class alu_transaction;

    localparam int WIDTH = 8;

    typedef enum bit [1:0] {ADD = 2'b00, SUB = 2'b01, AND_OP = 2'b10, OR_OP = 2'b11} alu_fun_e;

    rand bit [WIDTH-1:0] a;
    rand bit [WIDTH-1:0] b;
    rand alu_fun_e       alu_fun;
    rand bit             alu_enable;
    rand bit             rst;
    bit [WIDTH-1:0]      alu_out;
    bit                  alu_valid;

    constraint c_rst_default { rst == 1; } 

    constraint c_operand_dist {
        a dist { 8'h00 := 1, 8'hFF := 1, [8'h01:8'hFE] := 8 };
        b dist { 8'h00 := 1, 8'hFF := 1, [8'h01:8'hFE] := 8 };
    }

    constraint c_force_add_overflow { alu_fun == ADD -> (a + b) > 9'hFF; }
    constraint c_force_sub_borrow   { alu_fun == SUB -> a < b; }

    function alu_transaction copy();
        copy = new();
        copy.a          = this.a;
        copy.b          = this.b;
        copy.alu_fun    = this.alu_fun;
        copy.alu_enable = this.alu_enable;
        copy.rst        = this.rst;
        copy.alu_out    = this.alu_out;
        copy.alu_valid  = this.alu_valid;
    endfunction

    function string convert2string();
        return $sformatf("rst=%0b fun=%s en=%0b a=%0h b=%0h | out=%0h valid=%0b",
                          rst, alu_fun.name(), alu_enable, a, b, alu_out, alu_valid);
    endfunction

endclass
