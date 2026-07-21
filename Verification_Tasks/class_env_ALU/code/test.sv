`timescale 1ns/1ps

`include "transaction.sv"
`include "generator.sv"
`include "monitor.sv"
`include "driver.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "interface.sv"

module test;
intf alu_intf();
enviroment e;
alu dut (.a(alu_intf.a),.b(alu_intf.b),.opcode(alu_intf.opcode),.result(alu_intf.result));


initial begin
    e = new(alu_intf);
    e.run_enviroment();
    #2; // for the monitor to capture the last transaction
    e.sb.display_results();
    $stop;
end

endmodule
