module alu_test ();
    import pkg::*;

    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~ clk;
        end
    end

    alu_intf alu_if (clk, rst_n);
    ALU dut (alu_if);
    virtual alu_intf vif;
    env_class env;

    initial begin
        vif = alu_if;
        $display("%0t : ------------------------- Assert reset -------------------------", $realtime);
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        rst_n = 1'b1;
        $display("%0t : ------------------------- Reset deasserted-------------------------", $realtime);

        env = new(vif);
        env.run_env();

        #112;
        $display("------------------------------------------------------");
        $display("Simulation finished");
        $display("Correct_Count = %0d , Fail_Count = %0d", env.sb.pass_cnt, env.sb.fail_cnt);
        $display("------------------------------------------------------");
        $stop;
    end
endmodule