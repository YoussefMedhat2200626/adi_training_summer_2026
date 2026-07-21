class transaction;
  rand bit rst;
  rand bit [3:0] A;
  rand bit [3:0] B;
  rand bit Cin;
  rand bit [1:0] Opcode;

  bit [3:0] Result;
  bit Carry;
  bit Borrow;
  bit Overflow;

  function void display(string name);
    $display("[%s] rst=%0b A=%0d B=%0d Cin=%0b Opcode=%0b | Result=%0d Carry=%0b Borrow=%0b Overflow=%0b", name, rst, A, B, Cin, Opcode, Result,
     Carry, Borrow, Overflow);
  endfunction
endclass
