package agent_pkg;
    import transaction_pkg::*;
    import alu_generator_pkg::*;
    import alu_driver_pkg::*;
    import monitor_pkg::*;

    class agent;
        virtual alu_if agent_if;
        generator gen;
        driver drv;
        monitor mon;

        function new();
            gen = new();
            drv = new();
            mon = new();
        endfunction

        task run();
            gen.gen_mbox = drv.drv_mbox;
            gen.gen_event = drv.drv_event;
            drv.driver_if = agent_if;
            mon.monitor_if = agent_if;

            fork
                gen.run();
                drv.run();
                mon.run();
            join_any
        endtask
    endclass : agent
endpackage : agent_pkg