class driver;
  virtual alu_intf intf;
  mailbox #(transaction) mbx;

  function new(virtual alu_intf intf, mailbox #(transaction) mbx);
    this.intf = intf;
    this.mbx = mbx;
  endfunction

  task run();
    forever begin
      transaction tr;
      mbx.get(tr);
      @(negedge intf.clk);
      intf.rst    <= tr.rst;
      intf.A      <= tr.A;
      intf.B      <= tr.B;
      intf.Cin    <= tr.Cin;
      intf.Opcode <= tr.Opcode;
    end
  endtask
endclass