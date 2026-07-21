class driver;
transaction t_driv;
mailbox driv_mail;
event driv_handover;
virtual intf driv_intf;

  function new();
    this.driv_mail = new();
  endfunction

  task run_driver();
    
    forever begin
    t_driv = new();
    driv_mail.get(t_driv);
    #5; //delay between drives sence there is no clk
    t_driv.display("driver");
    //load transaction into interface
    driv_intf.a = t_driv.a;
    driv_intf.b = t_driv.b;
    driv_intf.opcode = t_driv.opcode;

    ->driv_handover;
    end
  endtask
endclass
