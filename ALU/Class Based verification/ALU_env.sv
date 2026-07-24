`include "ALU_agt.sv"
`include "ALU_scb.sv"

class alu_env;
    alu_agent agent;
    alu_scb   scb;
    mailbox #(alu_trans) mon2scb;

    function new(virtual alu_if vif);
        mon2scb = new();
        agent   = new(vif, mon2scb);
        scb     = new(mon2scb);
    endfunction

    task run();
        fork
            agent.run();
            scb.run();
        join_any
    endtask
endclass