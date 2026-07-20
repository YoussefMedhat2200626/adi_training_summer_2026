
class alu_test;

    // Environment instance
    alu_env env;

    // Constructor
    function new(virtual alu_if vif);
        env = new(vif);
    endfunction

    // Run test based on selected scenario
    task run_test(int scenario = 0);
        // Configure generator
        env.gen.scenario = scenario;
        env.gen.num_txns = 100;
        
        // Start environment
        env.run();
    endtask

endclass
