`include "ALU_env.sv"

class alu_test;
    alu_env env;

    function new(virtual alu_if vif);
        env = new(vif);
    endfunction

    task run();
        env.agent.gen.num_transactions = 100;
        
        env.run();
    endtask
endclass