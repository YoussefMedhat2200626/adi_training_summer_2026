import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;


class ALU_agent;
    ALU_driver driver;
    ALU_monitor monitor;
    mailbox#(ALU_transaction) gen_to_drv_mail;
    mailbox#(ALU_transaction) mon_to_sub_mail;
    event driver_handover;
    
    function new();
        this.gen_to_drv_mail = new();
        this.mon_to_sub_mail = new();
        this.driver = new();
        this.monitor = new();
        
        // Connect mailboxes
        driver.driver_mail = this.gen_to_drv_mail;
        driver.driver_handover = this.driver_handover;
        monitor.monitor_mail = this.mon_to_sub_mail;
    endfunction
    
    task run_agent();
        fork
            driver.run_driver();
            monitor.run_monitor();
        join_none
    endtask
    
    function void set_interface(virtual ALU_if vif);
        driver.driver_if = vif;
        monitor.monitor_if = vif;
    endfunction
endclass