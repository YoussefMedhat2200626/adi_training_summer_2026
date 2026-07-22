class env_class;
    agent_class ag;
    scoreboard_class sb;
    virtual alu_intf vif;
    mailbox #(transaction_class) env_sb_mon_mb = new(1);

    function void env_build ();
        ag = new(env_sb_mon_mb, vif);
        sb = new(env_sb_mon_mb);
    endfunction

    function new (virtual alu_intf test_vif);
        vif = test_vif;
        env_build();
    endfunction

    task run_env ();
        fork
            ag.run_agent();
            sb.run_scoreboard();
        join_none

        wait (ag.gen.send_tr.triggered);
        repeat (5) @(posedge ag.vif.clk);
    endtask
endclass