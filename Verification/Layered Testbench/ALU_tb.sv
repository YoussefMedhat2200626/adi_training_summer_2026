import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;
import ALU_cvg_pkg::*;

module ALU_tb;
    bit clk = 0;
    // Generate 10ns clock (100MHz)
    always #5 clk = ~clk;
    
    // Instantiate interface
    ALU_if alu_if(clk);
    
    // Instantiate DUT
    ALU dut(alu_if.DUT);
    
    // Testbench components
    ALU_test test;
    
    
    initial begin
        test = new();
        test.set_interface(alu_if);
        test.set_test_duration(50000);  
        
        $display("\n=== Simulation Started at %0t ===", $time);
        test.run_test();

        $display("=== Simulation Finished at %0t ===", $time);
        $stop;
    end
    
    initial begin
        $dumpfile("ALU_tb.vcd");
        $dumpvars;
    end
    
    initial begin
    $monitor("Time=%0t rst_n=%0d A=%0d B=%0d opcode=%s ALU_OUT=%0d carry=%0d arith=%0d logic=%0d zero=%0d",
              $time, alu_if.rst_n, alu_if.A, alu_if.B, alu_if.opcode.name(),
              alu_if.ALU_OUT, alu_if.carry_flag, alu_if.arith_flag, alu_if.logic_flag, alu_if.zero_flag);
    end 
    
endmodule