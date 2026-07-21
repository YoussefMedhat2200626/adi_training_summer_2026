`ifndef MONITOR_SV
`define MONITOR_SV

`include "transaction.sv"

class monitor;
  virtual alu_if           vif;
  mailbox #(transaction)   mon2sb;
  transaction              trans;

  function new(virtual alu_if vif, mailbox #(transaction) mon2sb);
    this.vif    = vif;
    this.mon2sb = mon2sb;
  endfunction

  task run();
    forever begin
      #5; // Wait for driver update & settlement
      trans              = new();
      trans.A            = vif.A;
      trans.B            = vif.B;
      trans.opcode       = vif.opcode;
      trans.Result       = vif.Result;
      trans.Zero         = vif.Zero;
      trans.Carry        = vif.Carry;
      trans.Overflow     = vif.Overflow;

      trans.display("MONITOR");
      mon2sb.put(trans);
    end
  endtask
endclass

`endif