class generator;
  transaction tr;
  mailbox #(transaction) mbx;
  int repeat_count = 10;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    repeat (repeat_count) begin
      tr = new();
      if (!tr.randomize()) $fatal("randomization failed!");
      mbx.put(tr);
    end
  endtask
endclass
