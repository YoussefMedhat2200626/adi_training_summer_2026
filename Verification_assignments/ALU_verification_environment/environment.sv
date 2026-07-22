package alu_environment_pkg;
    import agent_pkg::*;
    import scoreboard_pkg::*;

    class environment;
        agent agt;
        scoreboard scb;
        virtual alu_if env_if;

        task run();
            agt = new();
            scb = new();

            agt.agent_if = env_if;
            scb.sb_mbox = agt.mon.mon_mbox_u;

            fork 
                agt.run();
                scb.run();
            join_any

            while ((scb.pass_count + scb.fail_count) < 105)
                @(negedge env_if.CLK);

            scb.report();
            
        endtask
    endclass : environment
endpackage : alu_environment_pkg