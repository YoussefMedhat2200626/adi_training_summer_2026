class alu_env;
    alu_agent      agent;
    alu_scoreboard scb;
    mailbox #(alu_transaction) mon2scb;

    function new(virtual alu_interface vif);
        mon2scb = new();
        agent   = new(vif, mon2scb);
        scb     = new(mon2scb);
    endfunction

    task run_all_scenarios();
        agent.run();
        fork
            scb.run();
        join_none

        $display("\n==================================================");
        $display("   STARTING ALU TESTBENCH SCENARIO SUITE         ");
        $display("==================================================");

        $display("\n[TEST] Scenario 1: Executing Opcode Sweep Sequence...");
        agent.gen.run_scenario_1_opcode_sweep();

        $display("[TEST] Scenario 2: Executing Boundary Sequence...");
        agent.gen.run_scenario_2_boundary();

        $display("[TEST] Scenario 3 & 5: Executing Carryout Generation & Clear Sequence...");
        agent.gen.run_scenario_3_carry_and_clear();

        $display("[TEST] Scenario 4: Executing Zero Flag Target Sequence...");
        agent.gen.run_scenario_4_zero_flag();

        $display("[TEST] Scenario 5: Executing Constrained Random Sequence (1000 items)...");
        agent.gen.run_scenario_5_random(1000);

        #50;
        $display("\n==================================================");
        $display("            VERIFICATION SUMMARY REPORT           ");
        $display("==================================================");
        $display("  Total Passed Transactions : %0d", scb.pass_count);
        $display("  Total Failed Transactions : %0d", scb.fail_count);
        $display("  Functional Coverage       : %0.2f%%", scb.alu_cg.get_inst_coverage());
        $display("==================================================\n");
    endtask
endclass