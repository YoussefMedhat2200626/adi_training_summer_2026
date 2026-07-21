`ifndef ENVIRONMENT_SV
`define ENVIRONMENT_SV

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"

class environment;

  agent      agnt; // Matches agnt handle
  scoreboard scb;

  mailbox #(transaction) mon2sb;
  virtual alu_if vif;

  function new(virtual alu_if vif);
    this.vif    = vif;
    this.mon2sb = new();
    
    this.agnt   = new(vif, mon2sb);
    this.scb    = new(mon2sb);
  endfunction

  task pre_test();
    agnt.drv.reset();
  endtask

  task test();
    fork
      agnt.run();
      scb.run();
    join_any
  endtask

  task post_test();
    wait(agnt.gen.ended.triggered);
    #100;
    scb.report();
  endtask

  task report();
    scb.report();
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass

`endif