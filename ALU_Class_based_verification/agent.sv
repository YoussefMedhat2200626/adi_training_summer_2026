class agent;
  generator gen;
  driver drv;
  monitor mon;

  mailbox #(transaction) gen2drv_mbx;
  mailbox #(transaction) mon2scb_mbx;

  virtual alu_intf intf;

  function new(virtual alu_intf intf, mailbox #(transaction) mon2scb_mbx);
    this.intf = intf;
    this.mon2scb_mbx = mon2scb_mbx;
    
    gen2drv_mbx = new();
    gen = new(gen2drv_mbx);
    drv = new(intf, gen2drv_mbx);
    mon = new(intf, mon2scb_mbx);
  endfunction

  task run();
    fork
      gen.run();
      drv.run();
      mon.run();
    join_any
  endtask
endclass
