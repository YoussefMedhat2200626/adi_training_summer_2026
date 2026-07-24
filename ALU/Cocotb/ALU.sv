module alu #(parameter WIDTH = 8) ( alu_if vif );

    // Operation Encodings
    typedef enum logic [2:0] {
        ADD = 3'b000,
        SUB = 3'b001,
        AND = 3'b010,
        OR  = 3'b011,
        XOR = 3'b100,
        NOT = 3'b101, 
        SLL = 3'b110,
        SRL = 3'b111
    } opcode_e;

    logic [WIDTH:0] result; // Extra bit for carry evaluation

    assign vif.zero = !(|vif.out);

    always_ff @(posedge vif.clk or negedge vif.rst_n) begin
        if (!vif.rst_n) begin
            vif.out      <= '0;
            vif.carry    <= 1'b0;
            vif.overflow <= 1'b0;
        end else begin
            // Default flag values
            vif.carry    <= 1'b0;
            vif.overflow <= 1'b0;
            
            case (vif.opcode)
                ADD: begin
                    result = vif.a + vif.b;
                    {vif.carry, vif.out} <= result;
                    vif.overflow <= (~vif.a[WIDTH-1] & ~vif.b[WIDTH-1] & result[WIDTH-1]) | 
                                    (vif.a[WIDTH-1] & vif.b[WIDTH-1] & ~result[WIDTH-1]);
                end
                SUB: begin
                    result = vif.a - vif.b;
                    vif.out <= result[WIDTH-1:0];
                    vif.overflow <= (~vif.a[WIDTH-1] & vif.b[WIDTH-1] & result[WIDTH-1]) | 
                                    (vif.a[WIDTH-1] & ~vif.b[WIDTH-1] & ~result[WIDTH-1]);
                end
                AND: vif.out <= vif.a & vif.b;
                OR:  vif.out <= vif.a | vif.b;
                XOR: vif.out <= vif.a ^ vif.b;
                NOT: vif.out <= ~vif.a;
                SLL: vif.out <= vif.a << vif.b[2:0];
                SRL: vif.out <= vif.a >> vif.b[2:0];
                default: vif.out <= '0;
            endcase
        end
    end
endmodule