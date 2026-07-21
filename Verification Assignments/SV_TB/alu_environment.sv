// bundles agent + scoreboard
class alu_environment;

    alu_agent      agent;
    alu_scoreboard scoreboard;

    mailbox #(alu_transaction) mon2scb;

    function new(virtual alu_if vif, int num_transactions);
        // monitor samples num_transactions + 2 cycles: one extra to
        // establish "prev" with no check, one extra to observe the
        // registered output of the LAST driven transaction (pipeline flush)
        int num_samples = num_transactions + 2;

        mon2scb = new();

        agent      = new(vif, mon2scb, num_transactions, num_samples);
        scoreboard = new(mon2scb, num_samples);
    endfunction

    task run();
        fork
            agent.run();
            scoreboard.run();
        join
    endtask

endclass
