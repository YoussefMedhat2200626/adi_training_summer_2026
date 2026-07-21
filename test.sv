module test(alu_intf intf);
  env environment;

  initial begin
    environment = new(intf);
    environment.agt.gen.repeat_count = 20;  
    environment.run();
  end
endmodule