
`timescale 1ns/1ps

module ahb_lite_master_tb;

    localparam MAX_BEATS = 16;
    localparam DW        = 32;

    reg         HCLK;
    reg         HRESETn;

    reg         start;
    reg         wr_en;
    reg  [31:0] start_addr;
    reg  [2:0]  burst_type;
    wire        busy, done, error;

    reg  [31:0] src_data [0:MAX_BEATS-1];
    wire [MAX_BEATS*DW-1:0] wdata_bus;

    wire        rdata_valid;
    wire [31:0] rdata_out;
    wire [3:0]  rbeat_num;

    wire [31:0] HADDR;
    wire        HWRITE;
    wire [2:0]  HSIZE, HBURST;
    wire [1:0]  HTRANS;
    wire [31:0] HWDATA;
    wire        HREADY;
    wire        HRESP;
    wire [31:0] HRDATA;

    reg [3:0]   wait_states;
    reg [31:0]  cap_data [0:MAX_BEATS-1];
    integer     i;

    genvar g;
    generate
        for (g = 0; g < MAX_BEATS; g = g + 1) begin : PACK
            assign wdata_bus[g*DW +: DW] = src_data[g];
        end
    endgenerate

    ahb_lite_master #(.AW(32), .DW(32), .MAX_BEATS(MAX_BEATS)) dut (
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),
        .HADDR       (HADDR),
        .HWRITE      (HWRITE),
        .HSIZE       (HSIZE),
        .HBURST      (HBURST),
        .HTRANS      (HTRANS),
        .HWDATA      (HWDATA),
        .HREADY      (HREADY),
        .HRESP       (HRESP),
        .HRDATA      (HRDATA),
        .start       (start),
        .wr_en       (wr_en),
        .start_addr  (start_addr),
        .burst_type  (burst_type),
        .wdata_bus   (wdata_bus),
        .busy        (busy),
        .done        (done),
        .error       (error),
        .rdata_valid (rdata_valid),
        .rdata_out   (rdata_out),
        .rbeat_num   (rbeat_num)
    );

    ahb_lite_slave_model #(.AW(32), .DW(32), .MEM_WDS(64)) slv (
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),
        .HSEL        (1'b1),
        .HADDR       (HADDR),
        .HWRITE      (HWRITE),
        .HTRANS      (HTRANS),
        .HWDATA      (HWDATA),
        .HREADY      (HREADY),
        .HREADYOUT   (HREADY),
        .HRESP       (HRESP),
        .HRDATA      (HRDATA),
        .wait_states  (wait_states)
    );

    // 100 MHz clock
    initial HCLK = 0;
    always #5 HCLK = ~HCLK;

    // capture read bursts as they stream out of the master
    always @(posedge HCLK) begin
        if (rdata_valid) cap_data[rbeat_num] <= rdata_out;
    end

    task run_burst(input wr, input [31:0] addr, input [2:0] btype);
        begin
            @(posedge HCLK);
            start      <= 1'b1;
            wr_en      <= wr;
            start_addr <= addr;
            burst_type <= btype;
            @(posedge HCLK);
            start <= 1'b0;
            wait (done || error);
            @(posedge HCLK);
        end
    endtask

    initial begin
        HRESETn     = 0;
        start       = 0;
        wr_en       = 0;
        start_addr  = 0;
        burst_type  = 0;
        wait_states = 0;

        for (i = 0; i < MAX_BEATS; i = i + 1) 
            src_data[i] = 32'hA000_0000 + i;

        repeat (4) @(posedge HCLK);
        HRESETn = 1;
        repeat (2) @(posedge HCLK);

        // Test 1: single write then single read, no wait states
        $display("Test 1: single write/read");
        run_burst(1'b1, 32'h0000_0000, 3'b000); 
        run_burst(1'b0, 32'h0000_0000, 3'b000); 
        @(posedge HCLK);
        if (cap_data[0] === src_data[0])
            $display("  PASS: 0x%08h", cap_data[0]);
        else
            $display("  FAIL: got 0x%08h expected 0x%08h", cap_data[0], src_data[0]);

        // Test 2/Test 3: INCR4 write burst then INCR4 read burst, no wait states
        $display("Test 2/Test 3: INCR4 write+read burst");
        run_burst(1'b1, 32'h0000_0010, 3'b011); 
        run_burst(1'b0, 32'h0000_0010, 3'b011); 
        @(posedge HCLK);
        for (i = 0; i < 4; i = i + 1) begin
            if (cap_data[i] === src_data[i])
                $display("  PASS beat %0d: 0x%08h", i, cap_data[i]);
            else
                $display("  FAIL beat %0d: got 0x%08h expected 0x%08h", i, cap_data[i], src_data[i]);
        end

        // T4: INCR8 write+read burst WITH wait states inserted by slave
        $display("T4: INCR8 with wait states");
        wait_states = 2;
        run_burst(1'b1, 32'h0000_0020, 3'b101); // INCR8 write
        run_burst(1'b0, 32'h0000_0020, 3'b101); // INCR8 read
        @(posedge HCLK);
        for (i = 0; i < 8; i = i + 1) begin
            if (cap_data[i] === src_data[i])
                $display("  PASS beat %0d: 0x%08h", i, cap_data[i]);
            else
                $display("  FAIL beat %0d: got 0x%08h expected 0x%08h", i, cap_data[i], src_data[i]);
        end
        wait_states = 0;

        // T5: ERROR response aborts an INCR4 burst partway through
        $display("T5: ERROR response abort");
        run_burst(1'b0, 32'hDEAD_0000, 3'b011); // INCR4 read at error address
        if (error)
            $display("  PASS: master reported error and aborted the burst");
        else
            $display("  FAIL: master did not flag the error response");

        $display("All tests complete.");
        $finish;
    end

    initial begin
        $dumpfile("ahb_lite_master_tb.vcd");
        $dumpvars(0, ahb_lite_master_tb);
    end

endmodule
