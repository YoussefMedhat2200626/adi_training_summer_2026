module AHB_wrapper_tb();

    parameter WIDTH = 32;

    logic [WIDTH - 1 : 0] W_ADDR_S;
    logic W_WRITE_S;
    logic [2 : 0] W_BURST_S;
    logic W_ENABLE_S;
    logic [WIDTH - 1 : 0] W_WDATA_S;
    logic W_HCLK;
    logic W_HRESETn;
    logic [WIDTH - 1 : 0] W_HRDATA;

    int pass_count = 0;
    int error_count = 0;
    logic [WIDTH - 1 : 0] data_save [$]; // save the data from write burst to check on it in read burst
    int i = 0;
    int j = 0;

    // Instantiate the AHB Wrapper Top Module
    AHB_wrapper dut (
        .W_ADDR_S(W_ADDR_S),
        .W_WRITE_S(W_WRITE_S),
        .W_BURST_S(W_BURST_S),
        .W_ENABLE_S(W_ENABLE_S),
        .W_WDATA_S(W_WDATA_S),
        .W_HCLK(W_HCLK),
        .W_HRESETn(W_HRESETn),
        .W_HRDATA(W_HRDATA)
    );

    // Clock Generation: 10ns period
    initial begin
        W_HCLK = 0;
        forever #5 W_HCLK = ~ W_HCLK;
    end

    // Main Test Stimulus
    initial begin
        $readmemh("mem.dat", dut.slave.mem);

        $display("==================================================");
        $display("#-------- STARTING AHB WRAPPER SELF-CHECKING TESTBENCH --------");
        $display("==================================================");

        $display("-------- ASSERT RESET --------");
        assert_reset();

        $display("-------- SINGLE WRITE WITHOUT WAIT --------");
        write_single_no_wait();

        $display("-------- SINGLE WRITE WITH WAIT --------");
        write_single_with_wait();

        $display("-------- SINGLE READ WITHOUT WAIT --------");
        read_single_no_wait();

        $display("-------- SINGLE READ WITH WAIT --------");
        read_single_with_wait();

        $display("-------- WRITE BURST --------");
        write_burst();

        $display("-------- READ BURST --------");
        read_burst();

        // --- Summary ---
        #20;
        $display("==================================================");
        $display("-------- TEST Finshed -------- ");
        $display("==================================================");
        $display("pass count = %0d", pass_count);
        $display("error count = %0d", error_count);
        $display("==================================================");
        $stop;
    end

    // Task 1: Assert & deassert reset
    task assert_reset ();
        W_HRESETn = 1'b0;
        W_ADDR_S = 32'h00000000;
        W_WRITE_S = 1'b1;
        W_BURST_S = 3'b000;
        W_ENABLE_S = 1'b1;
        W_WDATA_S = 32'h00000000;

        repeat (2) @(negedge W_HCLK);

        if (W_HRDATA == 32'h00000000) begin
            $display("%0t : [Pass] Reset check", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] Reset check", $realtime);
            error_count++;
        end

        W_HRESETn = 1'b1;
    endtask

    // Task 2: Single Write without wait
    task write_single_no_wait ();
        // first write
        W_ADDR_S = 32'h00000000;
        W_WRITE_S = 1'b1;
        W_BURST_S = 3'b000;
        W_ENABLE_S = 1'b1;
        W_WDATA_S = 32'h10101010;

        repeat (8) @(negedge W_HCLK);

        if (dut.slave.mem[32'h00000000] == 32'h10101010) begin
            $display("%0t : [Pass] single write check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single write check without wait", $realtime);
            error_count++;
        end
        
        // second write
        W_WDATA_S = 32'h10101011;
        W_ADDR_S = 32'h00000001;

        repeat (8) @(negedge W_HCLK);

        if (dut.slave.mem[32'h00000001] == 32'h10101011) begin
            $display("%0t : [Pass] single write check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single write check without wait", $realtime);
            error_count++;
        end
        
        // third write
        W_WDATA_S = 32'h00110011;
        W_ADDR_S = 32'h00000002;

        repeat (8) @(negedge W_HCLK);

        if (dut.slave.mem[32'h00000002] == 32'h00110011) begin
            $display("%0t : [Pass] single write check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single write check without wait", $realtime);
            error_count++;
        end
    endtask

    // Task 3: single write with wait
    task write_single_with_wait ();
        W_ADDR_S = 32'h00000003;
        W_WRITE_S = 1'b1;
        W_BURST_S = 3'b000;
        W_ENABLE_S = 1'b1;
        W_WDATA_S = 32'h01010101;

        repeat (2) @(negedge W_HCLK);
        
        W_ENABLE_S = 1'b0;
        repeat (8) @(negedge W_HCLK);
        W_ENABLE_S = 1'b1;
        repeat (2) @(negedge W_HCLK);

        if (dut.slave.mem[32'h00000003] == 32'h01010101) begin
            $display("%0t : [Pass] single write check with wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single write check with wait", $realtime);
            error_count++;
        end
    endtask

    // Task 4: Single read without wait
    task read_single_no_wait ();
        // first read
        W_ADDR_S = 32'h00000000;
        W_WRITE_S = 1'b0;
        W_BURST_S = 3'b000;
        W_ENABLE_S = 1'b1;

        repeat (8) @(negedge W_HCLK);

        if (W_HRDATA == 32'h10101010) begin
            $display("%0t : [Pass] single read check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single read check without wait", $realtime);
            error_count++;
        end

        // second read
        W_ADDR_S = 32'h00000001;

        repeat (8) @(negedge W_HCLK);

        if (W_HRDATA == 32'h10101011) begin
            $display("%0t : [Pass] single read check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single read check without wait", $realtime);
            error_count++;
        end
        
        // third read
        W_ADDR_S = 32'h00000002;

        repeat (8) @(negedge W_HCLK);

        if (W_HRDATA == 32'h00110011) begin
            $display("%0t : [Pass] single read check without wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single read check without wait", $realtime);
            error_count++;
        end
    endtask

    // Task 5: Single read with wait
    task read_single_with_wait ();
        W_ADDR_S = 32'h00000003;
        W_WRITE_S = 1'b0;
        W_BURST_S = 3'b000;
        W_ENABLE_S = 1'b1;

        repeat (2) @(negedge W_HCLK);
        
        W_ENABLE_S = 1'b0;
        repeat (8) @(negedge W_HCLK);
        W_ENABLE_S = 1'b1;
        repeat (2) @(negedge W_HCLK);

        if (W_HRDATA == 32'h01010101) begin
            $display("%0t : [Pass] single read check with wait", $realtime);
            pass_count++;
        end
        else begin
            $display("%0t : [Fail] single read check with wait", $realtime);
            error_count++;
        end
    endtask

    // Task 6: write burst
    task write_burst ();
        W_ADDR_S = 32'b00000000;
        W_WRITE_S = 1'b1;
        W_BURST_S = 3'b001;
        W_ENABLE_S = 1'b1;

        for (i = 0; i < 30; i+=4) begin
            W_WDATA_S = $random;
            data_save.push_back(W_WDATA_S);
            $display("%0t : data_save[%0d] = %0h", $realtime, j, data_save[j]);
            j++;

            repeat (4) @(negedge W_HCLK);
        end

        W_BURST_S = 3'b000;
        j = 0;
        repeat (4) @(negedge W_HCLK);
    endtask

    // Task 7: read burst
    task read_burst ();
        W_ADDR_S = 32'h00000000;
        W_WRITE_S = 1'b0;
        W_BURST_S = 3'b001;
        W_ENABLE_S = 1'b1;

        for (i = 0; i < 60; i+=8) begin
            repeat (4) @(negedge W_HCLK);

            if (W_HRDATA == data_save[j]) begin
                $display("%0t : [Pass] read burst check", $realtime);
                pass_count++;
            end
            else begin
                $display("%0t : [Fail] read burst check", $realtime);
                error_count++;
            end
            j++;
        end
    endtask

endmodule