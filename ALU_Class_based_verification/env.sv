class env;
  agent agt;
  scoreboard scb;
  mailbox #(transaction) mon2scb_mbx;

  virtual alu_intf intf;

  function new(virtual alu_intf intf);
    this.intf = intf;
    mon2scb_mbx = new();
    agt = new(intf, mon2scb_mbx);
    scb = new(mon2scb_mbx);
  endfunction

  task run();
    fork
      agt.run();
      scb.run();
    join_any
  endtask
endclass
