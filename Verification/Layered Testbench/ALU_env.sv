import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;
import ALU_cvg_pkg::*;

class ALU_env;
    ALU_generator generator;
    ALU_agent agent;
    ALU_subscriber subscriber;
    ALU_scoreboard scoreboard;
    ALU_coverage coverage;
    
    mailbox#(ALU_transaction) sub_to_scb_mail;
    mailbox#(ALU_transaction) sub_to_cvg_mail;
    
    function new();
        sub_to_scb_mail = new();
        sub_to_cvg_mail = new();
        
        generator = new();
        agent = new();
        subscriber = new();
        scoreboard = new();
        coverage = new();
        
        // Connect generator to agent
        generator.gen_mail = agent.gen_to_drv_mail;

        // Connect generator's handover event to the SAME event object the
        // driver holds.
        generator.gen_handover = agent.driver_handover;
        
        // Connect monitor to subscriber.
        agent.monitor.monitor_mail = subscriber.sub_mail;
        
        // Connect subscriber to scoreboard and coverage
        subscriber.scoreboard_mail = sub_to_scb_mail;
        subscriber.coverage_mail = sub_to_cvg_mail;
        
        // Connect scoreboard
        scoreboard.score_mail = sub_to_scb_mail;
        
        // Connect coverage
        coverage.cvg_mail = sub_to_cvg_mail;
    endfunction
    
    task run_env();
        fork
            generator.run_generator();
            agent.run_agent();
            subscriber.run_subscriber();
            scoreboard.run_scoreboard();
            coverage.run_coverage();
        join_none
    endtask
    
    function void set_interface(virtual ALU_if vif);
        agent.set_interface(vif);
    endfunction
    
    function void report();
        $display("\n========== TEST REPORT ==========");
        $display("Total correct comparisons: %0d", correct_count);
        $display("Total error comparisons: %0d", error_count);
        $display("==================================\n");
    endfunction
endclass