`timescale 1ns/1ps

`include "intf.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

module tb; 

  bit clk;
  always #5 clk = ~clk;

  alu_if i_intf(clk); // Instantiated using alu_if type
  test t;

  simple_alu DUT (
    .A        (i_intf.A),
    .B        (i_intf.B),
    .opcode   (i_intf.opcode),
    .Result   (i_intf.Result),
    .Zero     (i_intf.Zero),
    .Carry    (i_intf.Carry),
    .Overflow (i_intf.Overflow)
  );

  initial begin
    t = new(i_intf);
    t.run();
    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule