`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "subscriber.sv"
`include "agent.sv"
`include "environment.sv"

module tb();

    intf intf1();

    environment env;

    initial begin
        env          = new();
        env.env_intf = intf1;
        env.run_environment();
    end

    initial begin
        intf1.clk = 1'b0;
    end

    always begin
        #5 intf1.clk = ~intf1.clk;
    end

    alu ALU (
        .clk    (intf1.clk    ),
        .rst_n  (intf1.rst_n  ),
        .A      (intf1.A      ),
        .B      (intf1.B      ),
        .opcode (intf1.opcode ),
        .result (intf1.result ),
        .carry  (intf1.carry  )
    );

endmodule
