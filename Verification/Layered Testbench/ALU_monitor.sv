import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;

class ALU_monitor;
    ALU_transaction t_monitor;
    virtual ALU_if monitor_if;
    mailbox#(ALU_transaction) monitor_mail;
    
    function new();
        this.monitor_mail = new();
    endfunction
    
    task run_monitor();
        forever begin
            t_monitor = new();
            @(posedge monitor_if.clk);
            #1step;
            
            
            t_monitor.rst_n = monitor_if.rst_n;
            t_monitor.A = monitor_if.A;
            t_monitor.B = monitor_if.B;
            t_monitor.opcode = monitor_if.opcode;
            t_monitor.ALU_OUT = monitor_if.ALU_OUT;
            t_monitor.carry_flag = monitor_if.carry_flag;
            t_monitor.arith_flag = monitor_if.arith_flag;
            t_monitor.logic_flag = monitor_if.logic_flag;
            t_monitor.zero_flag = monitor_if.zero_flag;
            
            monitor_mail.put(t_monitor);
        end
    endtask
endclass