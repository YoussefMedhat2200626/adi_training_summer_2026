class monitor;

    string       name        ;
    transaction  t_mon         ;
    mailbox      mon_mail_s    ;
    mailbox      mon_mail_su   ;
    virtual intf mon_intf       ;

    function new(string name = "MONITOR");
        this.name        = name;
        this.mon_mail_s  = new();
        this.mon_mail_su = new();
    endfunction

    task run_monitor();

        forever begin

            @(posedge mon_intf.clk);
            #1;

            t_mon         = new();
            t_mon.rst_n   = mon_intf.rst_n  ;
            t_mon.A       = mon_intf.A      ;
            t_mon.B       = mon_intf.B      ;
            t_mon.opcode  = mon_intf.opcode ;
            t_mon.result  = mon_intf.result ;
            t_mon.carry   = mon_intf.carry  ;

            mon_mail_s.put(t_mon)  ;
            mon_mail_su.put(t_mon) ;

            t_mon.display_transaction("MONITOR");
            $display("Monitor has received the data from the DUT at time : %0t", $realtime());

        end

    endtask

endclass
