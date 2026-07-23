`timescale 1ns/1ps

module tb_spi_slave;

    logic rst_n;
    logic SCLK;
    logic MOSI;
    logic MISO;
    logic CSn;
    
    int fail_count = 0;

    spi_slave u_dut (
        .rst_n(rst_n),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .CSn(CSn)
    );

    task automatic spi_write(input logic [6:0] addr, input logic [7:0] data);
        logic [15:0] tx_frame;
        tx_frame = {1'b1, addr, data}; 

        CSn = 1'b0;
        #10;

        for (int i = 15; i >= 0; i--) begin
            MOSI = tx_frame[i];
            #10;
            SCLK = 1'b1; 
            #10;
            SCLK = 1'b0; 
        end
        
        #10;
        CSn = 1'b1; 
        #20;
    endtask

    task automatic spi_read(input logic [6:0] addr, output logic [7:0] rdata);
        logic [15:0] tx_frame;
        tx_frame = {1'b0, addr, 8'h00}; 

        CSn = 1'b0;
        #10;

        for (int i = 15; i >= 0; i--) begin
            MOSI = tx_frame[i];
            #10;
            SCLK = 1'b1; 

            if (i < 8) begin
                rdata[i] = MISO;
            end
            
            #10;
            SCLK = 1'b0; 
        end
        
        #10;
        CSn = 1'b1; 
        #20;
    endtask

    task automatic test_register_access();
        logic [7:0] read_val;
        $display("\n=======================================================");
        $display(" TEST 1: Register Read/Write Access");
        $display("=======================================================");

        $display("  -> Writing 0x55 to Register 0...");
        spi_write(7'd0, 8'h55);

        $display("  -> Writing 0xAA to Register 1...");
        spi_write(7'd1, 8'hAA);

        $display("  -> Writing 0x12 to Register 2...");
        spi_write(7'd2, 8'h12);

        $display("  -> Writing 0x34 to Register 3...");
        spi_write(7'd3, 8'h34);

        $display("\n  -> Reading back all 4 registers...");
        
        spi_read(7'd0, read_val);
        $display("  <- Read Reg 0: 0x%02h (Expected: 0x55)", read_val);
        if (read_val !== 8'h55) fail_count++;
        
        spi_read(7'd1, read_val);
        $display("  <- Read Reg 1: 0x%02h (Expected: 0xAA)", read_val);
        if (read_val !== 8'hAA) fail_count++;
        
        spi_read(7'd2, read_val);
        $display("  <- Read Reg 2: 0x%02h (Expected: 0x12)", read_val);
        if (read_val !== 8'h12) fail_count++;
        
        spi_read(7'd3, read_val);
        $display("  <- Read Reg 3: 0x%02h (Expected: 0x34)", read_val);
        if (read_val !== 8'h34) fail_count++;
        
        if (fail_count == 0) $display("  [PASS] All writes and reads matched exactly!");
    endtask

    initial begin
        $dumpfile("spi_slave.vcd");
        $dumpvars(0, tb_spi_slave);

        SCLK  = 1'b0;
        MOSI  = 1'b0;
        CSn   = 1'b1;
        rst_n = 1'b0;

        #20 rst_n = 1'b1;
        #20;

        test_register_access();
        
        $display("\n=======================================================");
        if (fail_count == 0) $display(" ALL ASSIGNMENT 2 TESTS PASSED! ");
        else                 $display(" SOME TESTS FAILED (%0d failures).", fail_count);
        $display("=======================================================\n");
        
        $finish;
    end

endmodule
