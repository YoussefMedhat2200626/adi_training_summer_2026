module tb_top;
  bit clk;
  alu_intf intf(clk);

  alu DUT (.clk(intf.clk), .rst(intf.rst),  .A(intf.A), .B(intf.B), .Cin(intf.Cin), .Opcode(intf.Opcode), .Result(intf.Result), 
  .Carry(intf.Carry),.Borrow(intf.Borrow),.Overflow(intf.Overflow));

  test t1(intf);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  initial begin
    #300 $finish;
  end
endmodule
