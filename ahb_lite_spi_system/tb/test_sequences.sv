

`ifndef TEST_SEQUENCES_SV
`define TEST_SEQUENCES_SV

        task automatic wait_cmd_ready();
        wait(cmd_ready);
        @(posedge HCLK);
    endtask

        task automatic issue_cmd(
        input logic [31:0] addr,
        input logic [31:0] wdata,
        input logic        write,
        input logic [2:0]  size,
        input logic [2:0]  burst,
        input logic        last
    );
        wait_cmd_ready();
        cmd_valid <= 1'b1;
        cmd_addr  <= addr;
        cmd_wdata <= wdata;
        cmd_write <= write;
        cmd_size  <= size;
        cmd_burst <= burst;
        cmd_last  <= last;
        @(posedge HCLK);
        cmd_valid <= 1'b0;
    endtask

        task automatic provide_wdata(input logic [31:0] wdata);
        
        wait(HREADY);
        cmd_wdata <= wdata;
        @(posedge HCLK);
    endtask

        task automatic capture_rdata(output logic [31:0] rdata);
        while (1) begin
            @(posedge HCLK);
            #1;
            if (rsp_valid) begin
                rdata = rsp_rdata;
                break;
            end
        end
    endtask

        task automatic check(input string name, input logic [31:0] actual, input logic [31:0] expected);
        if (actual === expected) begin
            $display("  [PASS] %s: 0x%08X", name, actual);
            pass_count++;
        end else begin
            $display("  [FAIL] %s: Expected 0x%08X, Got 0x%08X", name, expected, actual);
            fail_count++;
        end
    endtask

    task automatic test_single_write();
        $display("\n--- Test 1: Single Write ---");
        issue_cmd(32'h0000_0000, 32'hDEAD_BEEF, 1'b1, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        wait(rsp_valid);
        @(posedge HCLK);
        $display("  Write completed.");
    endtask

    task automatic test_single_read();
        logic [31:0] rdata;
        $display("\n--- Test 2: Single Read ---");
        issue_cmd(32'h0000_0000, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata);
        check("Read 0x0000_0000", rdata, 32'hDEAD_BEEF);
    endtask

    task automatic test_write_read_verify();
        logic [31:0] rdata;
        $display("\n--- Test 3: Write Read Verify ---");
        issue_cmd(32'h0000_0404, 32'hCAFE_BABE, 1'b1, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        wait(rsp_valid); @(posedge HCLK);
        issue_cmd(32'h0000_0404, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata);
        check("Read 0x0000_0404", rdata, 32'hCAFE_BABE);
    endtask

    task automatic test_back_to_back_writes();
        $display("\n--- Test 4: Back to Back Writes ---");
        wait_cmd_ready();
        
        cmd_valid <= 1'b1; cmd_write <= 1'b1; cmd_size <= HSIZE_WORD; cmd_burst <= HBURST_SINGLE; cmd_last <= 1'b1;

        cmd_addr <= 32'h0000_0800; cmd_wdata <= 32'h1111_1111;
        do @(posedge HCLK); while(!cmd_ready);

        cmd_addr <= 32'h0000_0804; cmd_wdata <= 32'h2222_2222;
        do @(posedge HCLK); while(!cmd_ready);

        cmd_addr <= 32'h0000_0808; cmd_wdata <= 32'h3333_3333;
        do @(posedge HCLK); while(!cmd_ready);
        
        cmd_valid <= 1'b0;
        wait(rsp_valid); @(posedge HCLK); 
        $display("  B2B Writes completed.");
    endtask

    task automatic test_back_to_back_reads();
        logic [31:0] rdata1, rdata2, rdata3, rdata4;
        $display("\n--- Test 5: Back to Back Reads ---");
        
        wait_cmd_ready();
        cmd_valid <= 1'b1; cmd_write <= 1'b0; cmd_size <= HSIZE_WORD; cmd_burst <= HBURST_SINGLE; cmd_last <= 1'b1;
        
        fork
            begin
                
                cmd_addr <= 32'h0000_0800;
                do @(posedge HCLK); while(!cmd_ready);

                cmd_addr <= 32'h0000_0804;
                do @(posedge HCLK); while(!cmd_ready);

                cmd_addr <= 32'h0000_0808;
                do @(posedge HCLK); while(!cmd_ready);
                
                cmd_valid <= 1'b0;
            end
            begin
                
                capture_rdata(rdata1);
                capture_rdata(rdata2);
                capture_rdata(rdata3);
            end
        join
        
        check("Read 1", rdata1, 32'h1111_1111);
        check("Read 2", rdata2, 32'h2222_2222);
        check("Read 3", rdata3, 32'h3333_3333);
    endtask

    task automatic test_write_then_read_pipeline();
        logic [31:0] rdata;
        $display("\n--- Test 6: Write Then Read Pipeline ---");
        
        wait_cmd_ready();
        cmd_valid <= 1'b1; cmd_size <= HSIZE_WORD; cmd_burst <= HBURST_SINGLE; cmd_last <= 1'b1;

        cmd_write <= 1'b1; cmd_addr <= 32'h0000_000C; cmd_wdata <= 32'hABCD_EF01;
        do @(posedge HCLK); while(!cmd_ready);

        fork
            begin
                cmd_write <= 1'b0; cmd_addr <= 32'h0000_000C;
                do @(posedge HCLK); while(!cmd_ready);
                cmd_valid <= 1'b0;
            end
            begin
                capture_rdata(rdata); 
                capture_rdata(rdata); 
            end
        join
        
        check("Pipelined Read", rdata, 32'hABCD_EF01);
    endtask

    task automatic test_incr4_write_burst();
        $display("\n--- Test 7: INCR4 Write Burst ---");
        issue_cmd(32'h0000_0410, 32'hAAAA_0000, 1'b1, HSIZE_WORD, HBURST_INCR4, 1'b0);
        
        provide_wdata(32'hAAAA_0001);
        provide_wdata(32'hAAAA_0002);
        provide_wdata(32'hAAAA_0003);
        
        wait(rsp_valid); @(posedge HCLK); 
        $display("  INCR4 Write completed.");
    endtask

    task automatic test_incr4_read_burst();
        logic [31:0] rdata;
        $display("\n--- Test 8: INCR4 Read Burst ---");
        issue_cmd(32'h0000_0410, 32'h0, 1'b0, HSIZE_WORD, HBURST_INCR4, 1'b0);
        
        capture_rdata(rdata); check("Beat 1", rdata, 32'hAAAA_0000);
        capture_rdata(rdata); check("Beat 2", rdata, 32'hAAAA_0001);
        capture_rdata(rdata); check("Beat 3", rdata, 32'hAAAA_0002);
        capture_rdata(rdata); check("Beat 4", rdata, 32'hAAAA_0003);
    endtask

    task automatic test_incr8_burst();
        logic [31:0] rdata;
        $display("\n--- Test 9: INCR8 Write and Read ---");

        issue_cmd(32'h0000_0820, 32'h8888_0000, 1'b1, HSIZE_WORD, HBURST_INCR8, 1'b0);
        for(int i=1; i<8; i++) provide_wdata(32'h8888_0000 + i);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0820, 32'h0, 1'b0, HSIZE_WORD, HBURST_INCR8, 1'b0);
        for(int i=0; i<8; i++) begin
            capture_rdata(rdata);
            check($sformatf("Beat %0d", i+1), rdata, 32'h8888_0000 + i);
        end
    endtask

    task automatic test_incr16_burst();
        logic [31:0] rdata;
        $display("\n--- Test 10: INCR16 Write and Read ---");

        issue_cmd(32'h0000_0040, 32'h1616_0000, 1'b1, HSIZE_WORD, HBURST_INCR16, 1'b0);
        for(int i=1; i<16; i++) provide_wdata(32'h1616_0000 + i);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0040, 32'h0, 1'b0, HSIZE_WORD, HBURST_INCR16, 1'b0);
        for(int i=0; i<16; i++) begin
            capture_rdata(rdata);
            check($sformatf("Beat %0d", i+1), rdata, 32'h1616_0000 + i);
        end
    endtask

    task automatic test_wrap4_word_burst();
        logic [31:0] rdata;
        $display("\n--- Test 11: WRAP4 Word Burst (Start at 0x34) ---");

        issue_cmd(32'h0000_0034, 32'hC000_0001, 1'b1, HSIZE_WORD, HBURST_WRAP4, 1'b0);
        provide_wdata(32'hC000_0002);
        provide_wdata(32'hC000_0003);
        provide_wdata(32'hC000_0004);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0034, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata); check("Addr 0x34", rdata, 32'hC000_0001);
        
        issue_cmd(32'h0000_0038, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata); check("Addr 0x38", rdata, 32'hC000_0002);
        
        issue_cmd(32'h0000_003C, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata); check("Addr 0x3C", rdata, 32'hC000_0003);
        
        issue_cmd(32'h0000_0030, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata); check("Addr 0x30", rdata, 32'hC000_0004);
    endtask

    task automatic test_wait_states();
        logic [31:0] rdata;
        $display("\n--- Test 12: Wait States (Random 1-3 delays) ---");
        
        issue_cmd(32'h0000_0420, 32'hDDDD_EEEE, 1'b1, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        wait(rsp_valid); @(posedge HCLK);
        
        issue_cmd(32'h0000_0420, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata);
        check("Read with wait states", rdata, 32'hDDDD_EEEE);
    endtask

    task automatic test_error_response();
        logic [31:0] dummy_rdata;
        $display("\n--- Test 13: Error Response ---");
        
        issue_cmd(32'h0000_08F0, 32'hEEEE_0001, 1'b1, HSIZE_WORD, HBURST_INCR4, 1'b0);

        capture_rdata(dummy_rdata);

        wait(rsp_error); 
        $display("  [PASS] Error flagged correctly on beat");
        pass_count++;

        wait(cmd_ready);
    endtask

    task automatic test_byte_halfword_access();
        logic [31:0] rdata;
        $display("\n--- Test 14: Byte and Halfword Access ---");

        issue_cmd(32'h0000_0080, 32'h1122_3344, 1'b1, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0082, 32'h9999_0000, 1'b1, HSIZE_HALF, HBURST_SINGLE, 1'b1);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0080, 32'h0000_00FF, 1'b1, HSIZE_BYTE, HBURST_SINGLE, 1'b1);
        wait(rsp_valid); @(posedge HCLK);

        issue_cmd(32'h0000_0080, 32'h0, 1'b0, HSIZE_WORD, HBURST_SINGLE, 1'b1);
        capture_rdata(rdata);

        check("Byte/Halfword Mod", rdata, 32'h9999_33FF);
    endtask

    task automatic test_reset_during_transfer();
        $display("\n--- Test 15: Reset During Transfer ---");
        issue_cmd(32'h0000_00A0, 32'hFFFF_FFFF, 1'b1, HSIZE_WORD, HBURST_INCR16, 1'b0);

        wait(rsp_valid); @(posedge HCLK);
        wait(rsp_valid); @(posedge HCLK);

        HRESETn = 0;
        @(posedge HCLK);
        HRESETn = 1;
        @(posedge HCLK);

        if (cmd_ready) begin
            $display("  [PASS] Master recovered cleanly to IDLE");
            pass_count++;
        end else begin
            $display("  [FAIL] Master did not recover to IDLE");
            fail_count++;
        end
    endtask

`endif
