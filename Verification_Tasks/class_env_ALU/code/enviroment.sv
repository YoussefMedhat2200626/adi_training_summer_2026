class enviroment;
  agent a;
  scoreboard sb;
  virtual intf env_intf;

function new(virtual intf vif);
    this.env_intf = vif;
endfunction

task run_enviroment();
    a = new();
    sb = new();

    a.agnt_intf = env_intf;
    sb.score_mail = a.agnt_mail;

    fork
      a.run_agent();
      sb.run_scoreboard();
    join_any

endtask
endclass
