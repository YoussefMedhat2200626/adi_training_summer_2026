`include "ALU_tr.sv"
`include "ALU_gen.sv"
`include "ALU_driv.sv"
`include "ALU_mon.sv"

class alu_agent;
    alu_gen gen;
    alu_drv drv;
    alu_mon mon;
    mailbox #(alu_trans) gen2drv;

    function new(virtual alu_if vif, mailbox #(alu_trans) mon2scb);
        gen2drv = new();
        gen = new(gen2drv);
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
    endfunction

    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
        join_any
    endtask
endclass