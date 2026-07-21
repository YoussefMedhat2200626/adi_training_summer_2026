`ifndef AGENT_SV
`define AGENT_SV

`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"

class agent;
  generator gen;
  driver    drv;
  monitor   mon;

  mailbox #(transaction) gen2drv;
  mailbox #(transaction) mon2sb;
  virtual alu_if         vif;

  function new(virtual alu_if vif, mailbox #(transaction) mon2sb);
    this.vif     = vif;
    this.mon2sb  = mon2sb;
    this.gen2drv = new();

    this.gen     = new(gen2drv);
    this.drv     = new(vif, gen2drv);
    this.mon     = new(vif, mon2sb);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
    join_any
  endtask
endclass

`endif