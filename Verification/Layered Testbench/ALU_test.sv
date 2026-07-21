import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;
import ALU_cvg_pkg::*;

class ALU_test;
    ALU_env env;
    virtual ALU_if test_vif;
    int test_duration = 50000;
    
    function new();
        env = new();
    endfunction
    
    task run_test();
        $display("\n========== Starting ALU Test ==========");
        $display("Test duration: %0d transactions", test_duration);
        
        // Reset DUT initially
        test_vif.rst_n = 0;
        @(negedge test_vif.clk);
        test_vif.rst_n = 1;
        $display("Time %0t: Reset deasserted", $time);
        

        // Run all components in parallel
        fork
            env.run_env();
            wait_for_test_completion();
        join
        
        env.report();
        $display("========== Test Completed ==========\n");
    endtask
    
    task wait_for_test_completion();
        wait(test_finished == 1);
        $display("Time %0t: Generator finished", $time);
        repeat(5) @(negedge test_vif.clk);
        $display("Time %0t: All transactions processed", $time);
    endtask
    
    function void set_interface(virtual ALU_if vif);
        test_vif = vif;
        env.set_interface(vif);
    endfunction
    
    function void set_test_duration(int duration);
        test_duration = duration;
        env.generator.TEST_SIZE = test_duration;
    endfunction
endclass