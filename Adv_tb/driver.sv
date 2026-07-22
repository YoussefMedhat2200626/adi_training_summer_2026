
class driver;

    string       name         ;
    transaction  t_driv         ;
    mailbox      driv_mail      ;
    event        driv_handover  ;
    virtual intf driv_intf       ;

    function new(string name = "DRIVER");
        this.name      = name;
        this.driv_mail = new();
    endfunction

    task run_driver();

        forever begin

            driv_mail.get(t_driv);

            if(t_driv.rst_n == 1'b0) begin
                driv_intf.rst_n  = 1'b0;
                driv_intf.A      = 4'd0;
                driv_intf.B      = 4'd0;
                driv_intf.opcode = 2'b00;
                #4;
                driv_intf.rst_n  = 1'b1;
            end
            else begin
                @(negedge driv_intf.clk);
                driv_intf.rst_n  = t_driv.rst_n  ;
                driv_intf.A      = t_driv.A      ;
                driv_intf.B      = t_driv.B      ;
                driv_intf.opcode = t_driv.opcode ;
            end

            t_driv.display_transaction("DRIVER");
            $display("Driver has inserted the data into the DUT at time : %0t", $realtime());

            ->driv_handover;
        end

    endtask

endclass
