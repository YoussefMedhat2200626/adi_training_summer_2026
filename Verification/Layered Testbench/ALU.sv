import ALU_shared_pkg :: *;
module ALU(
    ALU_if.DUT a_if
);

logic [WIDTH - 1:0] ALU_OUT_comb;
logic carry_flag_comb, arith_flag_comb, logic_flag_comb;
assign arith_flag_comb = (a_if.opcode == ADD || a_if.opcode == SUB);
assign logic_flag_comb = (a_if.opcode == AND || a_if.opcode == XOR);
always @* a_if.zero_flag = (a_if.ALU_OUT == 0);

always @(posedge a_if.clk, negedge a_if.rst_n) begin
    if (!a_if.rst_n) begin
        a_if.ALU_OUT <= 0;
        a_if.carry_flag <= 0;
        a_if.arith_flag <= 0;
        a_if.logic_flag <= 0;
    end else begin
        a_if.ALU_OUT <= ALU_OUT_comb;
        a_if.carry_flag <= carry_flag_comb;
        a_if.arith_flag <= arith_flag_comb;
        a_if.logic_flag <= logic_flag_comb;
    end
end

always @*begin
    carry_flag_comb = 0;
    case (a_if.opcode)
        ADD: {carry_flag_comb,ALU_OUT_comb} = a_if.A + a_if.B;
        SUB: {carry_flag_comb,ALU_OUT_comb} = a_if.A - a_if.B;
        AND: ALU_OUT_comb = a_if.A & a_if.B;
        XOR: ALU_OUT_comb = a_if.A ^ a_if.B;
        default: {carry_flag_comb,ALU_OUT_comb} = 0;
    endcase
end

// Assertions only compiled in simulation
`ifdef SIM
    // 1. Reset Behavior
    always_comb begin
        if (!a_if.rst_n) begin
            reset_check: assert final (a_if.ALU_OUT == 0 && 
                                       a_if.carry_flag == 0 && 
                                       a_if.arith_flag == 0 && 
                                       a_if.logic_flag == 0)
                                else $error("reset_check failed");
            reset_check_C: cover final (a_if.ALU_OUT == 0 && 
                                        a_if.carry_flag == 0 && 
                                        a_if.arith_flag == 0 && 
                                        a_if.logic_flag == 0);
        end
    end

    // 2. arith_flag_check
    property arith_flag_check;
        disable iff (!a_if.rst_n) @(posedge a_if.clk) (a_if.opcode == ADD || a_if.opcode == SUB) |=> a_if.arith_flag;
    endproperty

    // 3. logic_flag_check
    property logic_flag_check;
        disable iff (!a_if.rst_n) @(posedge a_if.clk) (a_if.opcode == AND || a_if.opcode == XOR) |=> a_if.logic_flag;
    endproperty
    

    // 4. zero_flag_check
    always_comb begin
        if (a_if.ALU_OUT == 0 && !a_if.rst_n) begin
            zero_flag_check: assert final (a_if.zero_flag)
                                else $error("zero_flag_check failed");
            zero_flag_check_C: cover final (a_if.zero_flag);
        end
    end



    ARITH_FLAG: assert property (arith_flag_check)
        else $error("Assertion ARITH_FLAG failed!");

    LOGIC_FLAG: assert property (logic_flag_check)
        else $error("Assertion LOGIC_FLAG failed!");


    ARITH_FLAG_C: cover property (arith_flag_check);
    LOGIC_FLAG_C: cover property (logic_flag_check);
    
`endif

endmodule