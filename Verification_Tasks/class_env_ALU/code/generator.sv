class generator;
transaction t_gen;
int iterations;
mailbox gen_mail;
event gen_handover;

  function new();
    this.gen_mail = new();
  endfunction

  task run_generator();
  t_gen = new();
  iterations = 100;// number of generated transactions 
   for(int i = 1; i <= iterations; i++) begin
    //direct tests
    if(i == 1) begin
    t_gen.a = 4'd15;
    t_gen.b = 4'd15;
    t_gen.opcode = 2'b00;//add 15+15
    gen_mail.put(t_gen);
    @(gen_handover);
    end

    else if(i == 2) begin
    t_gen.a = 4'd0;
    t_gen.b = 4'd15;
    t_gen.opcode = 2'b01;//subtract 0-15
    gen_mail.put(t_gen);
    @(gen_handover);
    end
    
    //random tests
    else begin
      assert(t_gen.randomize()) else $fatal("randomize failed");
      gen_mail.put(t_gen);
      @(gen_handover);
    end
   end
  endtask
endclass
