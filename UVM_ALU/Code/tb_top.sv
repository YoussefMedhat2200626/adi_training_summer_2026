module tb_top;
    import alu_pkg::*;

    // Interface Instantiation
    alu_interface vif();

    // DUT Instantiation
    ALU dut (
        .A        (vif.A),
        .B        (vif.B),
        .opcode   (vif.opcode),
        .carryout (vif.carryout),
        .zero_flag(vif.zero_flag),
        .Result   (vif.Result)
    );

    // Test environment execution
    alu_env env;

    initial begin
        env = new(vif);
        env.run_all_scenarios();
        $finish;
    end
endmodule