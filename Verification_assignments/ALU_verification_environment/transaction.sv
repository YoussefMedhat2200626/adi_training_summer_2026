package transaction_pkg;
  class alu_item #(parameter n = 4);
  
      rand bit RST;
      rand bit [n-1:0] A;
      rand bit [n-1:0] B;
      rand bit [1:0] OpSel;
  
      logic [n-1:0] Out;
      logic         Carry;
  
      constraint c_reset {
          RST dist { 1:/90, 0:/10 };
      }
  
      constraint c_default_range {
          A     inside {[0:15]};
          B     inside {[0:15]};
          OpSel inside {[0:3]};
      }
      
      function void display();
          $display("Time: %0t, A: %0d, B: %0d, OpSel: %0b", $time, A, B, OpSel);
      endfunction
  endclass : alu_item
endpackage : transaction_pkg