class agent;

    string       name       ;
    generator    g            ;
    driver       d            ;
    monitor      m            ;
    virtual intf agt_intf      ;

    function new(string name = "AGENT");
        this.name = name;

        g = new();
        d = new();
        m = new();

        g.gen_mail     = d.driv_mail     ;
        g.gen_handover = d.driv_handover ;
    endfunction

    task run_agent();

        d.driv_intf = agt_intf;
        m.mon_intf  = agt_intf;

        fork
            m.run_monitor()   ;
            d.run_driver()    ;
            g.run_generator() ;
        join_any

    endtask

endclass
