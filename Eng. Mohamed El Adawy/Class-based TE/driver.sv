`ifndef DRIVER_SV
`define DRIVER_SV

`include "transaction.sv"

class driver;
  virtual alu_if           vif;
  mailbox #(transaction)   gen2drv;
  transaction              trans;

  function new(virtual alu_if vif, mailbox #(transaction) gen2drv);
    this.vif     = vif;
    this.gen2drv = gen2drv;
  endfunction

  task reset();
    vif.A      <= 8'b0;
    vif.B      <= 8'b0;
    vif.opcode <= 3'b0;
    vif.rst    <= 1'b1;
    #10;
    vif.rst    <= 1'b0;
  endtask

  task run();
    forever begin
      gen2drv.get(trans);

      vif.A      <= trans.A;
      vif.B      <= trans.B;
      vif.opcode <= trans.opcode;

      trans.display("DRIVER");
      #5; // Allow combinational logic to settle
    end
  endtask
endclass

`endif