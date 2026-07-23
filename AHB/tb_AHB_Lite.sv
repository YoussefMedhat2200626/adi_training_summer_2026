`timescale 1ns/1ps

module tb_ahb_system;

    // System Clock and Reset
    logic hclk;
    logic hresetn;

    // Clock Generation
    always #5 hclk = ~hclk;

    // Microcontroller Interface Signals
    logic        i_req_valid;
    logic        i_req_write;
    logic [31:0] i_req_addr;
    logic [31:0] i_req_wdata;
    logic [2:0]  i_req_size;
    logic [2:0]  i_req_burst;
    logic        i_req_busy;
    logic [3:0]  i_req_prot;
    logic        i_req_lock;

    logic        o_req_ready;
    logic        o_resp_valid;
    logic [31:0] o_resp_rdata;
    logic        o_resp_error;

    // DUT Instantiation
    ahb_system_wrapper #(
        .MEM_BASE_ADDR      (32'h0000_0000), // Base address for the first slave
        .MEM_SIZE_PER_SLAVE (1024) // 1KB per slave
    ) dut (
        .hclk         (hclk),
        .hresetn      (hresetn),
        .i_req_valid  (i_req_valid),
        .i_req_write  (i_req_write),
        .i_req_addr   (i_req_addr),
        .i_req_wdata  (i_req_wdata),
        .i_req_size   (i_req_size),
        .i_req_burst  (i_req_burst),
        .i_req_busy   (i_req_busy),
        .i_req_prot   (i_req_prot),
        .i_req_lock   (i_req_lock),
        .o_req_ready  (o_req_ready),
        .o_resp_valid (o_resp_valid),
        .o_resp_rdata (o_resp_rdata),
        .o_resp_error (o_resp_error)
    );

    // Tasks

    // Single Write Request
    task write_single(input logic [31:0] addr, input logic [31:0] data, input logic [3:0] prot, input logic lock);
        @(posedge hclk);
        wait(o_req_ready); // Wait for master FSM to be in IDLE
        
        i_req_valid <= 1'b1;
        i_req_write <= 1'b1; // Write
        i_req_addr  <= addr;
        i_req_wdata <= data;
        i_req_size  <= 3'b010;  // 32-bit Word
        i_req_burst <= 3'b000;  // SINGLE
        i_req_prot  <= prot;
        i_req_lock  <= lock;
        i_req_busy  <= 1'b0;

        @(posedge hclk);
        i_req_valid <= 1'b0; // Deassert request after one cycle
        
        while (!o_resp_valid) @(posedge hclk); // Wait for response
        $display("[TIME %0t] WRITE | Addr: %08h | Data: %08h | Prot: 4'b%04b", $time, addr, data, prot);
    endtask

    // Single Read Request
    task read_single(input logic [31:0] addr, output logic [31:0] data);
        @(posedge hclk);
        wait(o_req_ready);
        
        i_req_valid <= 1'b1;
        i_req_write <= 1'b0; // Read
        i_req_addr  <= addr;
        i_req_size  <= 3'b010;
        i_req_burst <= 3'b000;
        i_req_prot  <= 4'b0011; 
        i_req_lock  <= 1'b0;
        i_req_busy  <= 1'b0;

        @(posedge hclk);
        i_req_valid <= 1'b0;
        
        while (!o_resp_valid) @(posedge hclk);
        data = o_resp_rdata;
        $display("[TIME %0t] READ  | Addr: %08h | Data: %08h", $time, addr, data);
    endtask

    // INCR4 Burst Write Request
    task write_burst_incr4(input logic [31:0] start_addr, input logic [31:0] d0, d1, d2, d3);
        @(posedge hclk);
        wait(o_req_ready);
        
        i_req_valid <= 1'b1;
        i_req_write <= 1'b1;
        i_req_addr  <= start_addr;
        i_req_wdata <= d0;      // Beat 0
        i_req_size  <= 3'b010;  // Word
        i_req_burst <= 3'b011;  // INCR4
        i_req_prot  <= 4'b0011;
        
        @(posedge hclk);
        i_req_valid <= 1'b0; 
        i_req_wdata <= d1;      // Prepare Beat 1 Data for the pipelining

        // Wait for beat 0 response, then feed beat 2
        while (!o_resp_valid) @(posedge hclk);
        i_req_wdata <= d2;      

        // Wait for beat 1 response, then feed beat 3
        @(posedge hclk); while (!o_resp_valid) @(posedge hclk);
        i_req_wdata <= d3;

        // Wait for beat 2 and 3 response
        repeat(2) begin
            @(posedge hclk); while (!o_resp_valid) @(posedge hclk);
        end

        $display("[TIME %0t] BURST INCR4 WRITE COMPLETED at Base address: %08h", $time, start_addr);
    endtask

    // Configurable Size Write Request
    task write_configurable(input logic [31:0] addr, input logic [31:0] data, input logic [2:0] size);
        @(posedge hclk);
        wait(o_req_ready);
        
        i_req_valid <= 1'b1;
        i_req_write <= 1'b1;
        i_req_addr  <= addr;
        i_req_wdata <= data;
        i_req_size  <= size;
        i_req_burst <= 3'b000;  // SINGLE
        i_req_prot  <= 4'b0011;
        i_req_lock  <= 1'b0;
        i_req_busy  <= 1'b0;

        @(posedge hclk);
        i_req_valid <= 1'b0; 
        
        while (!o_resp_valid) @(posedge hclk);
        $display("[TIME %0t] CONFIGURABLE WRITE | Addr: %08h | Data: %08h | Size: %04b", $time, addr, data, size);
    endtask

    // Main Test Sequence
    logic [31:0] read_val;

    initial begin

        // Initialization
        hclk        = 0;
        hresetn     = 0;
        i_req_valid = 0;
        i_req_write = 0;
        i_req_addr  = 0;
        i_req_wdata = 0;
        i_req_size  = 0;
        i_req_burst = 0;
        i_req_busy  = 0;
        i_req_prot  = 0;
        i_req_lock  = 0;

        // Deassert Reset
        repeat(3) @(posedge hclk);
        hresetn = 1;
        repeat(3) @(posedge hclk);

        // TESTCASE 1: Single Transfers
        $display("TESTCASE 1");
        
        // Write to Slave 0 (Base: 0x0000)
        write_single(32'h0000_0004, 32'hAAAA_1111, 4'b0011, 1'b0);
        // Write to Slave 1 (Base: 0x0400)
        write_single(32'h0000_0408, 32'hBBBB_2222, 4'b0011, 1'b0);
        // Write to Slave 2 (Base: 0x0800)
        write_single(32'h0000_080C, 32'hCCCC_3333, 4'b0011, 1'b0);

        // Read and check
        read_single(32'h0000_0004, read_val);
        if(read_val !== 32'hAAAA_1111) $error("Slave 0 Read Mismatch!");
        
        read_single(32'h0000_0408, read_val);
        if(read_val !== 32'hBBBB_2222) $error("Slave 1 Read Mismatch!");
        
        read_single(32'h0000_080C, read_val);
        if(read_val !== 32'hCCCC_3333) $error("Slave 2 Read Mismatch!");

        $display("\nTESTCASE 1 ended successfully.");
        // TESTCASE 2: Burst Transfer (INCR4)
        $display("\nTESTCASE 2");
        
        // Write a 4-beat burst to Slave 1
        write_burst_incr4(32'h0000_0410, 32'hD0D0_0000, 32'hD0D0_0001, 32'hD0D0_0002, 32'hD0D0_0003);

        // Read back the burst beats individually to verify address auto-increment
        read_single(32'h0000_0410, read_val);
        if(read_val !== 32'hD0D0_0000) $error("Burst Beat 0 Mismatch!");
        read_single(32'h0000_0414, read_val); // Auto-incremented by 4 (Word)
        if(read_val !== 32'hD0D0_0001) $error("Burst Beat 1 Mismatch!");
        read_single(32'h0000_0418, read_val);
        if(read_val !== 32'hD0D0_0002) $error("Burst Beat 2 Mismatch!");
        read_single(32'h0000_041C, read_val);
        if(read_val !== 32'hD0D0_0003) $error("Burst Beat 3 Mismatch!");

        $display("\nTESTCASE 2 ended successfully.");
        // TESTCASE 3: Byte and Halfword Transfers
        $display("\nTESTCASE 3");
        
        // Initialize a full 32-bit word in Slave 0 to all zeros
        write_single(32'h0000_0040, 32'h0000_0000, 4'b0011, 1'b0);
        
        // Write a Byte (8-bit) to the lowest byte address (Offset +0)
        write_configurable(32'h0000_0040, 32'hXXXX_XXAA, 3'b000); 
        
        // Write a Halfword (16-bit) to the upper two bytes (Offset +2)
        write_configurable(32'h0000_0042, 32'hBBCC_XXXX, 3'b001);

        // Read back the full 32-bit word to verify byte lane routing.
        read_single(32'h0000_0040, read_val);
        if(read_val !== 32'hBBCC_00AA) $error("Byte and Halfword Transfer Read Mismatch!");

        $display("\nTESTCASE 3 ended successfully.");
        // TESTCASE 4: BUSY Wait State Insertion
        $display("\nTESTCASE 4");
        
        @(posedge hclk);
        wait(o_req_ready);
        i_req_valid <= 1'b1;
        i_req_write <= 1'b1;
        i_req_addr  <= 32'h0000_0820; // Slave 2
        i_req_wdata <= 32'hF1F1_F1F1;
        i_req_size  <= 3'b010; 
        i_req_burst <= 3'b011; // INCR4
        
        @(posedge hclk);
        i_req_valid <= 1'b0; 
        i_req_wdata <= 32'hF2F2_F2F2;
        
        while (!o_resp_valid) @(posedge hclk);
        
        // Assert BUSY immediately after the first beat response
        i_req_busy  <= 1'b1; 
        $display("[TIME %0t] Microcontroller asserts BUSY.", $time);
        
        @(posedge hclk); while (!o_resp_valid) @(posedge hclk); // Wait for second beat response as it was already
                                                                //sampled while BUSY was asserted

        repeat(2) @(posedge hclk); // Simulate BUSY for 2 cycles
        
        // Resume transfer
        i_req_busy  <= 1'b0; 
        i_req_wdata <= 32'hF3F3_F3F3;
        $display("[TIME %0t] Microcontroller clears BUSY. Burst resumes.", $time);
        
        while (!o_resp_valid) @(posedge hclk);
        i_req_wdata <= 32'hF4F4_F4F4;

        @(posedge hclk); while (!o_resp_valid) @(posedge hclk);
        
        $display("\nTESTCASE 4 ended successfully.");
	        $stop;
    end
endmodule