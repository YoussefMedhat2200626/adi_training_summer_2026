class transaction;
randc bit [3:0] a;
randc bit [3:0] b;  
rand  bit [1:0] opcode;     
      bit [3:0] result;

function void display(input string name = "transaction");
    $display("%s: a=%0d, b=%0d, opcode=%0b" ,name, a, b, opcode);
endfunction
endclass