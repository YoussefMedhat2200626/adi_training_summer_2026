class agent_class;
    generator_class gen;
    driver_class driv;
    monitor_class mon;
    virtual alu_intf vif;

    mailbox #(transaction_class) agent_gen_driv_mb = new(1);
    mailbox #(transaction_class) agent_mon_sb_mb = new(1);

    function void agent_build ();
        gen = new(agent_gen_driv_mb);
        driv = new(agent_gen_driv_mb, vif);
        mon = new(agent_mon_sb_mb, vif);
    endfunction

    function new (mailbox #(transaction_class) env_mb, virtual alu_intf env_vif);
        agent_mon_sb_mb = env_mb;
        vif = env_vif;
        agent_build();
    endfunction

    task run_agent ();
        // fork
        //     driv.reset();
        // join

        fork
            gen.run_gen();
            driv.run_driv();
            mon.run_mon();
        join_none
        // disable fork;
    endtask

endclass