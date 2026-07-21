class monitor;
  virtual alu_intf intf;
  mailbox #(transaction) mbx;

  function new(virtual alu_intf intf, mailbox #(transaction) mbx);
    this.intf = intf;
    this.mbx = mbx;
  endfunction

  task run();
    forever begin
      transaction tr;
      @(posedge intf.clk);
      #1;
      tr = new();
      tr.rst      = intf.rst;
      tr.A        = intf.A;
      tr.B        = intf.B;
      tr.Cin      = intf.Cin;
      tr.Opcode   = intf.Opcode;
      tr.Result   = intf.Result;
      tr.Carry    = intf.Carry;
      tr.Borrow   = intf.Borrow;
      tr.Overflow = intf.Overflow;

      mbx.put(tr);
    end
  endtask
endclass