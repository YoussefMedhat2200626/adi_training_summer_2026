`timescale 1ns / 1ps

module tb_ahb_top;

    //--------------------------------------------------------------------
    // Testbench Parameters
    //--------------------------------------------------------------------
    parameter ADDR_WIDTH      = 32;
    parameter DATA_WIDTH      = 32;
    parameter FIFO_DEPTH      = 8;
    parameter FIFO_PTR_WIDTH  = 3;
    parameter MEM_DEPTH_BYTES = 4096;
    parameter WAIT_THRESHOLD  = 32'h00000100;
    parameter WAIT_CYCLES     = 2;

    // Constant Encoding
    localparam [2:0] HSIZE_HALFWORD = 3'b001;
    localparam [2:0] HSIZE_WORD     = 3'b010;
    localparam [2:0] HBURST_SINGLE  = 3'b000;
    localparam [2:0] HBURST_INCR    = 3'b001;

    //--------------------------------------------------------------------
    // Clock & Reset Signals
    //--------------------------------------------------------------------
    reg clk;
    reg rst_n;

    //--------------------------------------------------------------------
    // DUT Interface Signals
    //--------------------------------------------------------------------
    reg                  fifo_push;
    reg [ADDR_WIDTH-1:0] fifo_addr;
    reg                  fifo_write;
    reg [DATA_WIDTH-1:0] fifo_wdata;
    reg [2:0]            fifo_size;
    reg [2:0]            fifo_burst;
    reg [7:0]            fifo_burst_len;
    wire                 fifo_full;

    wire [DATA_WIDTH-1:0] rdata;
    wire                  rdata_valid;

    //--------------------------------------------------------------------
    // Scoreboard Array FIFO & Tracking (Verilog-2001 Array Model)
    //--------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] expected_read_mem [0:63];
    reg [5:0] exp_wr_ptr;
    reg [5:0] exp_rd_ptr;

    integer pass_count;
    integer fail_count;
    integer test_num;

    //--------------------------------------------------------------------
    // Clock Generation (100 MHz -> 10 ns period)
    //--------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------------------------
    // DUT Instantiation
    //--------------------------------------------------------------------
    ahb_top #(
        .ADDR_WIDTH      (ADDR_WIDTH),
        .DATA_WIDTH      (DATA_WIDTH),
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_PTR_WIDTH  (FIFO_PTR_WIDTH),
        .MEM_DEPTH_BYTES (MEM_DEPTH_BYTES),
        .WAIT_THRESHOLD  (WAIT_THRESHOLD),
        .WAIT_CYCLES     (WAIT_CYCLES)
    ) u_dut (
        .hclk_i           (clk),
        .hresetn_i        (rst_n),
        .fifo_push_i      (fifo_push),
        .fifo_addr_i      (fifo_addr),
        .fifo_write_i     (fifo_write),
        .fifo_wdata_i     (fifo_wdata),
        .fifo_size_i      (fifo_size),
        .fifo_burst_i     (fifo_burst),
        .fifo_burst_len_i (fifo_burst_len),
        .fifo_full_o      (fifo_full),
        .rdata_o          (rdata),
        .rdata_valid_o    (rdata_valid)
    );

    //--------------------------------------------------------------------
    // Scoreboard Checking Logic
    //--------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n && rdata_valid) begin
            if (exp_rd_ptr != exp_wr_ptr) begin
                if (rdata === expected_read_mem[exp_rd_ptr]) begin
                    $display("   |  [PASS] Time: %8t ps | Captured: 0x%8h | Expected: 0x%8h", 
                             $time, rdata, expected_read_mem[exp_rd_ptr]);
                    pass_count = pass_count + 1;
                end else begin
                    $display("   |  [FAIL] Time: %8t ps | Captured: 0x%8h | Expected: 0x%8h ***", 
                             $time, rdata, expected_read_mem[exp_rd_ptr]);
                    fail_count = fail_count + 1;
                end
                exp_rd_ptr = exp_rd_ptr + 1'b1;
            end else begin
                $display("   |  [ERROR] Time: %8t ps | Unexpected Read Data Captured: 0x%8h", $time, rdata);
                fail_count = fail_count + 1;
            end
        end
    end

    //--------------------------------------------------------------------
    // Verification Tasks (Strict Verilog-2001 Syntax)
    //--------------------------------------------------------------------
    task reset_dut;
        begin
            rst_n          = 0;
            fifo_push      = 0;
            fifo_addr      = 0;
            fifo_write     = 0;
            fifo_wdata     = 0;
            fifo_size      = HSIZE_WORD;
            fifo_burst     = HBURST_SINGLE;
            fifo_burst_len = 8'd1;
            exp_wr_ptr     = 0;
            exp_rd_ptr     = 0;
            pass_count     = 0;
            fail_count     = 0;
            test_num       = 0;
            repeat (3) @(posedge clk);
            rst_n          = 1;
            @(posedge clk);
            $display("   |  [SYSTEM] Hardware Reset Deasserted Successfully");
        end
    endtask

    task start_test;
        input integer num;
        begin
            test_num = num;
            $display("\n-----------------------------------------------------------------------------------");
            $display("[TEST %0d] Executing Test Case...", test_num);
            $display("-----------------------------------------------------------------------------------");
        end
    endtask

    task push_write;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] wdata;
        input [2:0]            size;
        begin
            while (fifo_full) @(posedge clk);
            fifo_push      <= 1'b1;
            fifo_addr      <= addr;
            fifo_write     <= 1'b1;
            fifo_wdata     <= wdata;
            fifo_size      <= size;
            fifo_burst     <= HBURST_SINGLE;
            fifo_burst_len <= 8'd1;
            @(posedge clk);
            fifo_push      <= 1'b0;
            $display("   |  [WRITE] Queueing Address: 0x%8h | Data: 0x%8h | Size Encoding: %0d", addr, wdata, size);
        end
    endtask

    task push_read;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] expected_data;
        input [2:0]            size;
        begin
            while (fifo_full) @(posedge clk);
            expected_read_mem[exp_wr_ptr] = expected_data;
            exp_wr_ptr = exp_wr_ptr + 1'b1;

            fifo_push      <= 1'b1;
            fifo_addr      <= addr;
            fifo_write     <= 1'b0;
            fifo_wdata     <= 32'h0;
            fifo_size      <= size;
            fifo_burst     <= HBURST_SINGLE;
            fifo_burst_len <= 8'd1;
            @(posedge clk);
            fifo_push      <= 1'b0;
            $display("   |  [READ ] Queueing Address: 0x%8h | Expected Data: 0x%8h", addr, expected_data);
        end
    endtask

    task push_burst_read_4;
        input [ADDR_WIDTH-1:0] start_addr;
        input [DATA_WIDTH-1:0] exp0;
        input [DATA_WIDTH-1:0] exp1;
        input [DATA_WIDTH-1:0] exp2;
        input [DATA_WIDTH-1:0] exp3;
        input [2:0]            size;
        begin
            while (fifo_full) @(posedge clk);

            expected_read_mem[exp_wr_ptr] = exp0; exp_wr_ptr = exp_wr_ptr + 1'b1;
            expected_read_mem[exp_wr_ptr] = exp1; exp_wr_ptr = exp_wr_ptr + 1'b1;
            expected_read_mem[exp_wr_ptr] = exp2; exp_wr_ptr = exp_wr_ptr + 1'b1;
            expected_read_mem[exp_wr_ptr] = exp3; exp_wr_ptr = exp_wr_ptr + 1'b1;

            fifo_push      <= 1'b1;
            fifo_addr      <= start_addr;
            fifo_write     <= 1'b0;
            fifo_wdata     <= 32'h0;
            fifo_size      <= size;
            fifo_burst     <= HBURST_INCR;
            fifo_burst_len <= 8'd4;
            @(posedge clk);
            fifo_push      <= 1'b0;
            $display("   |  [BURST READ] Address: 0x%8h | Beats: 4 | Type: INCR", start_addr);
        end
    endtask

    task print_summary;
        begin
            $display("\n===================================================================================");
            $display("                            VERIFICATION SUMMARY REPORT                            ");
            $display("===================================================================================");
            $display("   Total Tests Executed  : %0d", test_num);
            $display("   Total Checks Passed   : %0d", pass_count);
            $display("   Total Checks Failed   : %0d", fail_count);
            $display("-----------------------------------------------------------------------------------");
            if (fail_count == 0 && pass_count > 0) begin
                $display("   >>> STATUS: ALL TESTS PASSED SUCCESSFULLY! <<<");
            end else begin
                $display("   >>> STATUS: TESTBENCH FAILED WITH %0d ERRORS! <<<", fail_count);
            end
            $display("===================================================================================\n");
        end
    endtask

    //--------------------------------------------------------------------
    // Main Test Stimulus
    //--------------------------------------------------------------------
    initial begin
        $display("\n===================================================================================");
        $display("                   AHB-LITE MASTER COMPREHENSIVE VERIFICATION SUITE                ");
        $display("===================================================================================");

        reset_dut();

        // ---------------------------------------------------------------
        // TEST 1: Single Word Write & Read (0 Wait States)
        // ---------------------------------------------------------------
        start_test(1);
        $display("   |  Description: Single Word Write & Read (0 Wait States)");
        push_write(32'h00000010, 32'hDEADBEEF, HSIZE_WORD);
        push_read(32'h00000010, 32'hDEADBEEF, HSIZE_WORD);
        repeat (12) @(posedge clk);

        // ---------------------------------------------------------------
        // TEST 2: Halfword Write & Read Alignment
        // ---------------------------------------------------------------
        start_test(2);
        $display("   |  Description: Halfword Write & Read Alignment");
        push_write(32'h00000020, 32'h00001234, HSIZE_HALFWORD);
        push_read(32'h00000020, 32'h00001234, HSIZE_HALFWORD);
        repeat (12) @(posedge clk);

        // ---------------------------------------------------------------
        // TEST 3: Variable Slave Wait States (Address >= 0x00000100)
        // ---------------------------------------------------------------
        start_test(3);
        $display("   |  Description: Variable Slave Wait States (Addr >= 0x00000100 -> 2 Wait States)");
        push_write(32'h00000200, 32'hCAFEBABE, HSIZE_WORD);
        push_read(32'h00000200, 32'hCAFEBABE, HSIZE_WORD);
        repeat (20) @(posedge clk);

        // ---------------------------------------------------------------
        // TEST 4: 4-Beat INCR Burst Write & Read (0 Wait States)
        // ---------------------------------------------------------------
        start_test(4);
        $display("   |  Description: 4-Beat INCR Burst Write & Read (0 Wait States)");
        push_write(32'h00000040, 32'h11111111, HSIZE_WORD);
        push_write(32'h00000044, 32'h22222222, HSIZE_WORD);
        push_write(32'h00000048, 32'h33333333, HSIZE_WORD);
        push_write(32'h0000004C, 32'h44444444, HSIZE_WORD);
        repeat (15) @(posedge clk);

        push_burst_read_4(32'h00000040, 32'h11111111, 32'h22222222, 32'h33333333, 32'h44444444, HSIZE_WORD);
        repeat (25) @(posedge clk);

        // ---------------------------------------------------------------
        // TEST 5: 4-Beat INCR Burst Read with Wait States (Addr >= 0x00000100)
        // ---------------------------------------------------------------
        start_test(5);
        $display("   |  Description: 4-Beat INCR Burst Read with Wait States (Addr >= 0x00000100)");
        push_write(32'h00000300, 32'hAAAA0001, HSIZE_WORD);
        push_write(32'h00000304, 32'hAAAA0002, HSIZE_WORD);
        push_write(32'h00000308, 32'hAAAA0003, HSIZE_WORD);
        push_write(32'h0000030C, 32'hAAAA0004, HSIZE_WORD);
        repeat (25) @(posedge clk);

        push_burst_read_4(32'h00000300, 32'hAAAA0001, 32'hAAAA0002, 32'hAAAA0003, 32'hAAAA0004, HSIZE_WORD);
        repeat (35) @(posedge clk);

        // ---------------------------------------------------------------
        // TEST 6: Back-to-Back Request Queue Pipeline
        // ---------------------------------------------------------------
        start_test(6);
        $display("   |  Description: Back-to-Back Request Queue Pipeline");
        push_write(32'h00000050, 32'h55555555, HSIZE_WORD);
        push_read(32'h00000050, 32'h55555555, HSIZE_WORD);
        push_write(32'h00000054, 32'h66666666, HSIZE_WORD);
        push_read(32'h00000054, 32'h66666666, HSIZE_WORD);
        repeat (35) @(posedge clk);

        // Print Summary Report & Finish
        print_summary();
        $finish;
    end

endmodule