`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "transaction.sv"

class generator;
  transaction              trans;
  mailbox #(transaction)   gen2drv;
  int                      count;
  event                    ended; // Added to sync with environment post_test

  function new(mailbox #(transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task run();
    repeat (count) begin
      trans = new();
      if (!trans.randomize())
        $display("[GENERATOR] randomize() failed");

      trans.display("GENERATOR");
      gen2drv.put(trans);
    end
    -> ended; // Trigger when generation is complete
  endtask
endclass

`endif