`timescale 1ns/1ps

module tb_ahb_protocol_graphs;

    reg         HCLK;
    reg         HRESETn;

    reg         cmd_valid;
    reg  [31:0] cmd_addr;
    reg         cmd_write;
    reg  [2:0]  cmd_size;
    reg  [2:0]  cmd_burst;
    reg         cmd_lock;
    reg  [31:0] cmd_wdata;
    reg         cmd_busy;
    wire        cmd_ready;

    integer pass_count = 0;
    integer fail_count = 0;

    reg         slv_force_wait; 

    ahb_system_top uut (
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .cmd_valid      (cmd_valid),
        .cmd_addr       (cmd_addr),
        .cmd_write      (cmd_write),
        .cmd_size       (cmd_size),
        .cmd_burst      (cmd_burst),
        .cmd_lock       (cmd_lock),
        .cmd_wdata      (cmd_wdata),
        .cmd_busy       (cmd_busy),
        .cmd_ready      (cmd_ready),
        .slv_force_wait (slv_force_wait) 
    );

    initial begin
        HCLK = 0;
        forever #5 HCLK = ~HCLK;
    end

    task check_result;
        input [8*80:1] test_name;
        input          condition;
        begin
            if (condition) begin
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        HRESETn        = 0;
        cmd_valid      = 0;
        cmd_addr       = 0;
        cmd_write      = 0;
        cmd_size       = 0;
        cmd_burst      = 0;
        cmd_lock       = 0;
        cmd_wdata      = 0;
        cmd_busy       = 0;
        slv_force_wait = 0;

        #20;
        HRESETn = 1;
        #10;

        test_graph_basic_write();
        test_graph_basic_read();
        test_graph_pipelined_transfers();
        test_graph_master_busy();
        test_graph_wrap4_burst();
        test_graph_slave_wait_state();
        test_graph_figure_3_6_full();

        #50;
        $finish;
    end

    task automatic test_graph_basic_write;
        begin
            wait(cmd_ready); @(posedge HCLK);
            
            cmd_valid = 1; 
            cmd_write = 1; 
            cmd_addr  = 32'h0000_0010; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b000; 
            cmd_wdata = 32'hDEADBEEF; 
            
            @(posedge HCLK);
            cmd_valid = 0;
            
            wait(!cmd_ready);
            wait(cmd_ready); 
            @(posedge HCLK); 
            #1;               
            
            check_result("Graph 1: Write to 0x10 verified in slave memory", 
                         (uut.u_slave.mem[32'h10 >> 2] === 32'hDEADBEEF));
            #20;
        end
    endtask

    task automatic test_graph_basic_read;
        begin
            uut.u_slave.mem[32'h10 >> 2] = 32'hDEADBEEF;

            wait(cmd_ready); @(posedge HCLK);
            
            cmd_valid = 1; 
            cmd_write = 0; 
            cmd_addr  = 32'h0000_0010; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b000; 
            
            @(posedge HCLK);
            cmd_valid = 0;
            
            @(posedge HCLK); 
            #1;               
            
            check_result("Graph 2: Read from 0x10 returned correct data (0xDEADBEEF)", 
                         (uut.ahb_hrdata === 32'hDEADBEEF));
            #20;
        end
    endtask

    task automatic test_graph_pipelined_transfers;
        reg pass_burst;
        begin
            wait(cmd_ready); @(posedge HCLK);
            
            cmd_valid = 1; 
            cmd_write = 1; 
            cmd_addr  = 32'h0000_0040; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b011; 
            cmd_wdata = 32'hA1A1A1A1;
            
            @(posedge HCLK);
            cmd_valid = 0;
            
            wait(!cmd_ready); 
            wait(cmd_ready); 
            @(posedge HCLK); 
            #1;
            
            pass_burst = (uut.u_slave.mem[32'h40 >> 2] === 32'hA1A1A1A1) &&
                         (uut.u_slave.mem[32'h44 >> 2] === 32'hA1A1A1A2) &&
                         (uut.u_slave.mem[32'h48 >> 2] === 32'hA1A1A1A3) &&
                         (uut.u_slave.mem[32'h4C >> 2] === 32'hA1A1A1A4);

            check_result("Graph 3: INCR4 Pipelined Write written correctly to memory", pass_burst);
            #20;
        end
    endtask

    task automatic test_graph_master_busy;
        reg busy_state_detected;
        begin
            wait(cmd_ready); @(posedge HCLK);
            
            cmd_valid = 1; 
            cmd_write = 1; 
            cmd_addr  = 32'h0000_0080; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b011; 
            cmd_wdata = 32'hB2B2B2B2;
            
            @(posedge HCLK);
            cmd_valid = 0;
            
            wait(uut.ahb_htrans == 2'b11); 
            @(posedge HCLK);
            
            cmd_busy = 1;
            @(posedge HCLK); #1;
            
            busy_state_detected = (uut.ahb_htrans === 2'b01);
            check_result("Graph 4: Master drove HTRANS = BUSY (2'b01)", busy_state_detected);
            
            repeat(2) @(posedge HCLK);
            cmd_busy = 0;
            
            wait(!cmd_ready);
            wait(cmd_ready);
            #20;
        end
    endtask

    task automatic test_graph_wrap4_burst;
        reg [31:0] addr_seq [0:3];
        integer i;
        reg addr_pass;
        begin
            wait(cmd_ready); @(posedge HCLK);
            
            cmd_valid = 1; 
            cmd_write = 1; 
            cmd_addr  = 32'h0000_00C8; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b010; 
            cmd_wdata = 32'hC3C3C3C3;
            
            @(posedge HCLK);
            cmd_valid = 0;
            
            for (i = 0; i < 4; i = i + 1) begin
                if (i == 0) wait(uut.ahb_htrans == 2'b10); 
                else @(posedge HCLK);
                #1;
                addr_seq[i] = uut.ahb_haddr;
            end
            
            addr_pass = (addr_seq[0] === 32'h000000C8) &&
                        (addr_seq[1] === 32'h000000CC) &&
                        (addr_seq[2] === 32'h000000C0) &&
                        (addr_seq[3] === 32'h000000C4);
                        
            check_result("Graph 5: WRAP4 Address rollover sequence (C8 -> CC -> C0 -> C4)", addr_pass);

            wait(!cmd_ready);
            wait(cmd_ready);
            #20;
        end
    endtask

    task automatic test_graph_slave_wait_state;
        begin
            wait(cmd_ready); @(posedge HCLK);

            cmd_valid = 1; 
            cmd_write = 1;
            cmd_addr  = 32'h0000_0060; 
            cmd_size  = 3'b010; 
            cmd_burst = 3'b011; 
            
            @(posedge HCLK); 
            cmd_valid = 0;
            
            slv_force_wait = 1;
            #1;
            check_result("Graph 7 (Cycle 2): Master drives SEQ (2'b11) for Beat 2", 
                         (uut.ahb_htrans === 2'b11));
            check_result("Graph 7 (Cycle 2): HADDR is 0x64", 
                         (uut.ahb_haddr === 32'h0000_0064));

            @(posedge HCLK); 
            #1;
            check_result("Graph 7 (Cycle 3): Bus stalled. HTRANS held at SEQ", 
                         (uut.ahb_htrans === 2'b11));
            check_result("Graph 7 (Cycle 3): Bus stalled. HADDR held at 0x64", 
                         (uut.ahb_haddr === 32'h0000_0064));
                         
            @(posedge HCLK);
            slv_force_wait = 0;
            #1;
            check_result("Graph 7 (Cycle 4): Still holding HADDR at 0x64 before edge", 
                         (uut.ahb_haddr === 32'h0000_0064));

            @(posedge HCLK);
            #1;
            check_result("Graph 7 (Cycle 5): Bus resumes. HADDR increments to 0x68", 
                         (uut.ahb_haddr === 32'h0000_0068));

            wait(!cmd_ready);
            wait(cmd_ready);
            #20;
        end
    endtask
    
    task automatic test_graph_figure_3_6_full;
        begin
            uut.u_slave.mem[32'h20 >> 2] = 32'hD000_0020;
            uut.u_slave.mem[32'h24 >> 2] = 32'hD000_0024;
            uut.u_slave.mem[32'h28 >> 2] = 32'hD000_0028;
            uut.u_slave.mem[32'h2C >> 2] = 32'hD000_002C;

            wait(cmd_ready); @(posedge HCLK); 

            cmd_valid = 1; 
            cmd_write = 0;          
            cmd_addr  = 32'h0000_0020; 
            cmd_size  = 3'b010;     
            cmd_burst = 3'b011;     
            cmd_busy  = 0;          
            slv_force_wait = 0;
            
            wait(uut.ahb_htrans == 2'b10);
            
            #1;
            cmd_valid = 0;
            
            check_result("T0: HTRANS drives NONSEQ (2'b10)", (uut.ahb_htrans === 2'b10));
            check_result("T0: HADDR is 0x20",                (uut.ahb_haddr === 32'h0000_0020));
            
            cmd_busy = 1; 

            @(posedge HCLK); #1;
            
            check_result("T1: HTRANS drives BUSY (2'b01)",   (uut.ahb_htrans === 2'b01));
            check_result("T1: HADDR prepares 0x24",          (uut.ahb_haddr === 32'h0000_0024));
            check_result("T1: HRDATA reads Data (0x20)",     (uut.ahb_hrdata === 32'hD000_0020));

            cmd_busy = 0; 

            @(posedge HCLK); #1;
            
            check_result("T2: HTRANS resumes SEQ (2'b11)",   (uut.ahb_htrans === 2'b11));
            check_result("T2: HADDR holds 0x24",             (uut.ahb_haddr === 32'h0000_0024));

            @(posedge HCLK); #1;
            
            check_result("T3: HTRANS drives SEQ (2'b11)",    (uut.ahb_htrans === 2'b11));
            check_result("T3: HADDR increments to 0x28",     (uut.ahb_haddr === 32'h0000_0028));
            check_result("T3: HRDATA reads Data (0x24)",     (uut.ahb_hrdata === 32'hD000_0024));

            slv_force_wait = 1;

            @(posedge HCLK); #1;
            
            check_result("T4: HTRANS drives SEQ (2'b11)",    (uut.ahb_htrans === 2'b11));
            check_result("T4: HADDR increments to 0x2C",     (uut.ahb_haddr === 32'h0000_002C));
            check_result("T4: HREADY is pulled LOW",         (uut.ahb_hready === 1'b0));

            @(posedge HCLK); #1; 
            
            check_result("T5: HTRANS held at SEQ (2'b11)",   (uut.ahb_htrans === 2'b11));
            check_result("T5: HADDR held at 0x2C",           (uut.ahb_haddr === 32'h0000_002C));
            check_result("T5: HRDATA reads Data (0x28)",     (uut.ahb_hrdata === 32'hD000_0028));
            
            slv_force_wait = 0; 
            #1;
            check_result("T5: HREADY returns HIGH",          (uut.ahb_hready === 1'b1));

            @(posedge HCLK); #1;
            
            check_result("T6: HRDATA reads Data (0x2C)",     (uut.ahb_hrdata === 32'hD000_002C));

            wait(!cmd_ready);
            wait(cmd_ready);
            #20;
        end
    endtask

    initial begin
        $dumpfile("ahb_graphs.vcd");
        $dumpvars(0, tb_ahb_protocol_graphs);
    end

endmodule