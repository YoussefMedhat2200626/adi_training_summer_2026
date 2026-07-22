class environment;

    string       name       ;
    agent        a            ;
    scoreboard   s            ;
    subscriber   su           ;
    virtual intf env_intf      ;

    function new(string name = "ENVIRONMENT");
    this.name = name;

    a  = new();
    s  = new();
    su = new();

    s.scor_mail  = a.m.mon_mail_s  ;
    su.subs_mail = a.m.mon_mail_su ;

    endfunction

    task run_environment();

        a.agt_intf = env_intf;

        fork
            su.run_subscriber() ;
            s.run_scoreboard()  ;
            a.run_agent()       ;
        join_any

        @(negedge env_intf.clk);
        su.display_coverage_percentage();
        s.display_test_cases_report();
        $finish();

    endtask

endclass
