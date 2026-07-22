module tb();
    import alu_environment_pkg::*;

    reg CLK;
    alu_if alu_if_inst(CLK);
    environment env;
    alu DUT (
        .CLK(alu_if_inst.CLK),
        .RST(alu_if_inst.RST),
        .A(alu_if_inst.A),
        .B(alu_if_inst.B),
        .OpSel(alu_if_inst.OpSel),
        .Out(alu_if_inst.Out),
        .Carry(alu_if_inst.Carry)
    );

    initial begin
        env = new();
        env.env_if = alu_if_inst;
        env.run();
        $finish;
    end

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
endmodule : tb