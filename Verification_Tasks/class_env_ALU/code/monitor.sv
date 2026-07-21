class monitor;

transaction t_mon;
mailbox mon_mail;
virtual intf mon_intf;

function new();
    this.mon_mail = new();
endfunction

task run_monitor();
    t_mon = new();
    #1; //delay to allow driver to drive the interface and the monitor to sample it after #1
    forever begin
    #5;//delay between transactions
    t_mon.a      = mon_intf.a;
    t_mon.b      = mon_intf.b;
    t_mon.opcode = mon_intf.opcode;
    t_mon.result = mon_intf.result;
    mon_mail.put(t_mon);
    t_mon.display("monitor");
    end
endtask
endclass
