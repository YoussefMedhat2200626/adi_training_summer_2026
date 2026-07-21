`ifndef TEST_SV
`define TEST_SV

`include "environment.sv"

class test;
  environment env;
  virtual alu_if vif;

  function new(virtual alu_if vif);
    this.vif = vif;
    env = new(vif);
  endfunction

  task run();
    env.agnt.gen.count = 2000; 

    env.run();
    #30000;

    env.report();
    $display("[TEST] simulation finished");
  endtask
endclass

`endif