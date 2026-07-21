class agent;
monitor m;
driver d;
generator g;
virtual intf agnt_intf;
mailbox agnt_mail;

function new();
    this.agnt_mail = new();
endfunction

task run_agent();
m = new();
d = new();
g = new();

g.gen_mail = d.driv_mail;
g.gen_handover = d.driv_handover;

d.driv_intf = agnt_intf;
m.mon_intf = agnt_intf;

m.mon_mail = agnt_mail;

    fork
      m.run_monitor();
      d.run_driver();
      g.run_generator();
    join_any
endtask
endclass