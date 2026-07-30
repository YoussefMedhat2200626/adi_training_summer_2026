`timescale 1ns / 1ps

module tb_spi_slave;

    // Parameters
    localparam CLK_PERIOD = 100; // 10 MHz SPI Clock
    
    // Signals
    reg  tb_sclk;
    reg  tb_csb;
    reg  tb_sdi;
    wire tb_sdo;

    // Scoreboard and Stats
    reg [7:0] ref_mem [0:32767];
    integer errors = 0;
    integer trans_cnt = 0;
    
    // DUT Instantiation
    spi_top u_spi_top (
        .sclk (tb_sclk),
        .csb  (tb_csb),
        .sdi  (tb_sdi),
        .sdo  (tb_sdo)
    );

    // =========================================================================
    // Reusable SPI Driver Tasks (Master Emulation)
    // =========================================================================
    task spi_send_bit;
        input bit_val;
        begin
            tb_sdi = bit_val;
            #(CLK_PERIOD/2);
            tb_sclk = 1;
            #(CLK_PERIOD/2);
            tb_sclk = 0;
        end
    endtask

    task spi_send_header;
        input rw;
        input [14:0] addr;
        integer i;
        begin
            spi_send_bit(rw); // Bit 15
            for (i = 14; i >= 0; i = i - 1) begin
                spi_send_bit(addr[i]);
            end
        end
    endtask

    task spi_write_byte;
        input [7:0] data;
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                spi_send_bit(data[i]);
            end
        end
    endtask

    task spi_read_byte_check;
        input [7:0] expected_data;
        output [7:0] act_data;
        integer i;
        begin
            act_data = 8'h00;
            for (i = 7; i >= 0; i = i - 1) begin
                tb_sdi = 0;
                #(CLK_PERIOD/4); 
                
                // Turnaround check: Ensure slave drives data halfway through low phase
                if (tb_sdo !== expected_data[i]) begin
                    $display("[ERROR] Turnaround/Data mismatch at bit %0d. Exp: %02x, Got bit: %b", i, expected_data, tb_sdo);
                    errors = errors + 1;
                end
                
                #(CLK_PERIOD/4);
                tb_sclk = 1;
                act_data[i] = tb_sdo; // Master samples on rising edge
                #(CLK_PERIOD/2);
                tb_sclk = 0;
            end
        end
    endtask

    // =========================================================================
    // Test Sequence
    // =========================================================================
    integer i, j;
    reg [7:0] wdata, rdata;
    reg [14:0] rand_addr;

    initial begin
        // Initialize memory model and signals
        for (i = 0; i < 32768; i = i + 1) ref_mem[i] = 8'h00;
        tb_sclk = 0;
        tb_csb = 1;
        tb_sdi = 0;

        #(CLK_PERIOD * 5);
        $display("========================================");
        $display("   STARTING SPI SLAVE VERIFICATION      ");
        $display("========================================");

        // -----------------------------------------------------------
        $display("Test 1: Single-byte write");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h0010);
        spi_write_byte(8'hAB);
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        ref_mem[15'h0010] = 8'hAB;
        if (u_spi_top.u_register_map.memory[15'h0010] !== 8'hAB) errors = errors + 1;
        trans_cnt = trans_cnt + 1;

        // -----------------------------------------------------------
        $display("Test 2: Single-byte read");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b1, 15'h0010);
        spi_read_byte_check(8'hAB, rdata);
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        trans_cnt = trans_cnt + 1;

        // -----------------------------------------------------------
        $display("Test 3: Burst write");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h0100);
        for (i = 0; i < 4; i = i + 1) begin
            spi_write_byte(8'hC0 + i);
            ref_mem[15'h0100 + i] = 8'hC0 + i;
        end
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        for (i = 0; i < 4; i = i + 1) begin
            if (u_spi_top.u_register_map.memory[15'h0100 + i] !== (8'hC0 + i)) errors = errors + 1;
        end
        trans_cnt = trans_cnt + 1;

        // -----------------------------------------------------------
        $display("Test 4: Burst read");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b1, 15'h0100);
        for (i = 0; i < 4; i = i + 1) begin
            spi_read_byte_check(ref_mem[15'h0100 + i], rdata);
        end
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        trans_cnt = trans_cnt + 1;

        // -----------------------------------------------------------
        $display("Test 5: Random writes + compare (100 txns)");
        for (i = 0; i < 100; i = i + 1) begin
            rand_addr = $random % 32768;
            wdata = $random % 256;
            
            // Write
            tb_csb = 0; #(CLK_PERIOD/2);
            spi_send_header(1'b0, rand_addr);
            spi_write_byte(wdata);
            #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD/2);
            ref_mem[rand_addr] = wdata;
            
            // Read Back
            tb_csb = 0; #(CLK_PERIOD/2);
            spi_send_header(1'b1, rand_addr);
            spi_read_byte_check(wdata, rdata);
            #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD/2);
            trans_cnt = trans_cnt + 2;
        end

        // -----------------------------------------------------------
        $display("Test 6: Random burst transfers");
        rand_addr = 15'h2000;
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, rand_addr);
        for (i = 0; i < 8; i = i + 1) begin
            wdata = $random % 256;
            spi_write_byte(wdata);
            ref_mem[rand_addr + i] = wdata;
        end
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b1, rand_addr);
        for (i = 0; i < 8; i = i + 1) begin
            spi_read_byte_check(ref_mem[rand_addr + i], rdata);
        end
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        trans_cnt = trans_cnt + 2;

        // -----------------------------------------------------------
        $display("Test 7: CSB interruption");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h1234);
        spi_send_bit(1'b1);
        spi_send_bit(1'b0);
        spi_send_bit(1'b1);
        spi_send_bit(1'b0);
        // Abort mid-byte
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        if (u_spi_top.u_register_map.memory[15'h1234] === 8'hA0) errors = errors + 1; // Should not have written

        // -----------------------------------------------------------
        $display("Test 8: Address rollover");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h7FFE); // Max is 7FFF
        spi_write_byte(8'h11); ref_mem[15'h7FFE] = 8'h11;
        spi_write_byte(8'h22); ref_mem[15'h7FFF] = 8'h22;
        spi_write_byte(8'h33); ref_mem[15'h0000] = 8'h33;
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);

        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b1, 15'h7FFE);
        spi_read_byte_check(8'h11, rdata);
        spi_read_byte_check(8'h22, rdata);
        spi_read_byte_check(8'h33, rdata);
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);
        trans_cnt = trans_cnt + 2;

        // -----------------------------------------------------------
        $display("Test 9: Back-to-back transactions");
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h0050);
        spi_write_byte(8'h55);
        ref_mem[15'h0050] = 8'h55;
        #(CLK_PERIOD/2); tb_csb = 1; // Immediate raise/lower
        tb_csb = 0; #(CLK_PERIOD/2);
        spi_send_header(1'b0, 15'h0051);
        spi_write_byte(8'hAA);
        ref_mem[15'h0051] = 8'hAA;
        #(CLK_PERIOD/2); tb_csb = 1; #(CLK_PERIOD);

        // -----------------------------------------------------------
        $display("Test 10: Read turnaround timing (Verified natively in Test 2/4/5/8)");
        
        // Final Results Summary
        $display("========================================");
        $display("Transactions: %0d", trans_cnt);
        $display("Errors:       %0d", errors);
        if (errors == 0)
            $display(">>> ALL TESTS PASSED <<<");
        else
            $display(">>> TEST FAILED <<<");
        $display("========================================");
        
        $finish;
    end

    // Timeout protection
    initial begin
        #5000000;
        $display("TIMEOUT: Simulation took too long!");
        $finish;
    end

endmodule