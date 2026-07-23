

`timescale 1ns / 1ps

module tb_ahb_lite_system;
    import ahb_lite_pkg::*;

        logic HCLK;
    logic HRESETn;

        logic        cmd_valid;
    logic        cmd_ready;
    logic [31:0] cmd_addr;
    logic [31:0] cmd_wdata;
    logic        cmd_write;
    logic [2:0]  cmd_burst;
    logic [2:0]  cmd_size;
    logic        cmd_last;
    logic        rsp_valid;
    logic [31:0] rsp_rdata;
    logic        rsp_error;

        logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic [1:0]  HTRANS;
    logic        HWRITE;
    logic [2:0]  HSIZE;
    logic [2:0]  HBURST;
    logic [3:0]  HPROT;
    logic        HMASTLOCK;
    
        logic [31:0] HRDATA;
    logic        HREADY;
    logic        HRESP;

        logic HSEL_0, HSEL_1, HSEL_2;
    logic [31:0] HADDR_S;
    logic [31:0] HWDATA_S;
    logic [1:0]  HTRANS_S;
    logic        HWRITE_S;
    logic [2:0]  HSIZE_S;
    logic [2:0]  HBURST_S;
    logic        HREADY_S;
    
    logic [31:0] HRDATA_S0, HRDATA_S1, HRDATA_S2;
    logic        HREADYOUT_S0, HREADYOUT_S1, HREADYOUT_S2;
    logic        HRESP_S0, HRESP_S1, HRESP_S2;

    initial HCLK = 0;
    always #5 HCLK = ~HCLK; 

    ahb_lite_master u_master (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(HADDR), .HWDATA(HWDATA), .HTRANS(HTRANS), .HWRITE(HWRITE),
        .HSIZE(HSIZE), .HBURST(HBURST), .HPROT(HPROT), .HMASTLOCK(HMASTLOCK),
        .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP),
        .cmd_valid(cmd_valid), .cmd_ready(cmd_ready), .cmd_addr(cmd_addr),
        .cmd_wdata(cmd_wdata), .cmd_write(cmd_write), .cmd_burst(cmd_burst),
        .cmd_size(cmd_size), .cmd_last(cmd_last), .rsp_valid(rsp_valid),
        .rsp_rdata(rsp_rdata), .rsp_error(rsp_error)
    );

    ahb_interconnect u_interconnect (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(HADDR), .HWDATA(HWDATA), .HTRANS(HTRANS), .HWRITE(HWRITE),
        .HSIZE(HSIZE), .HBURST(HBURST),
        .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP),
        .HSEL_S0(HSEL_0), .HSEL_S1(HSEL_1), .HSEL_S2(HSEL_2),
        .HADDR_S(HADDR_S), .HWDATA_S(HWDATA_S),
        .HTRANS_S(HTRANS_S), .HWRITE_S(HWRITE_S), .HSIZE_S(HSIZE_S),
        .HBURST_S(HBURST_S), .HREADY_S(HREADY_S),
        .HRDATA_S0(HRDATA_S0), .HREADYOUT_S0(HREADYOUT_S0), .HRESP_S0(HRESP_S0),
        .HRDATA_S1(HRDATA_S1), .HREADYOUT_S1(HREADYOUT_S1), .HRESP_S1(HRESP_S1),
        .HRDATA_S2(HRDATA_S2), .HREADYOUT_S2(HREADYOUT_S2), .HRESP_S2(HRESP_S2)
    );

    ahb_slave_mem #(.WAIT_STATES(0)) u_slave_mem_0 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL_0),
        .HADDR(HADDR_S), .HWDATA(HWDATA_S), .HWRITE(HWRITE_S), .HSIZE(HSIZE_S),
        .HBURST(HBURST_S), .HTRANS(HTRANS_S), .HREADY(HREADY_S),
        .HRDATA(HRDATA_S0), .HREADYOUT(HREADYOUT_S0), .HRESP(HRESP_S0)
    );
    
    ahb_slave_mem #(.WAIT_STATES(0)) u_slave_mem_1 (
        .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL_1),
        .HADDR(HADDR_S), .HWDATA(HWDATA_S), .HWRITE(HWRITE_S), .HSIZE(HSIZE_S),
        .HBURST(HBURST_S), .HTRANS(HTRANS_S), .HREADY(HREADY_S),
        .HRDATA(HRDATA_S1), .HREADYOUT(HREADYOUT_S1), .HRESP(HRESP_S1)
    );

    logic [1:0] HTRANS_S2;
    assign HTRANS_S2 = HSEL_2 ? HTRANS_S : HTRANS_IDLE; 
    
    ahb_slave_bfm u_slave_bfm_2 (
        .HCLK(HCLK), .HRESETn(HRESETn),
        .HADDR(HADDR_S), .HWDATA(HWDATA_S), .HWRITE(HWRITE_S),
        .HSIZE(HSIZE_S), .HBURST(HBURST_S), .HTRANS(HTRANS_S2),
        .HRDATA(HRDATA_S2), .HREADYIN(HREADY_S), .HREADYOUT(HREADYOUT_S2), .HRESP(HRESP_S2)
    );

    integer pass_count = 0;
    integer fail_count = 0;

    `include "test_sequences.sv"

    initial begin
        
        cmd_valid = 0; cmd_addr = 0; cmd_wdata = 0; cmd_write = 0;
        cmd_burst = 0; cmd_size = 0; cmd_last = 0;

        HRESETn = 0;
        repeat (5) @(posedge HCLK);
        HRESETn = 1;
        repeat (2) @(posedge HCLK);

        $display("\n========================================================");
        $display("   AHB-LITE FULL SYSTEM VERIFICATION");
        $display("========================================================\n");

        test_single_write();
        test_single_read();
        test_write_read_verify();
        test_back_to_back_writes();
        test_back_to_back_reads();
        test_write_then_read_pipeline();
        
        test_incr4_write_burst();
        test_incr4_read_burst();
        test_incr8_burst();
        test_incr16_burst();
        
        test_wrap4_word_burst();

        u_slave_bfm_2.wait_state_count = 2; 
        test_wait_states();
        u_slave_bfm_2.wait_state_count = 0;

        u_slave_bfm_2.error_inject_en = 1'b1;
        u_slave_bfm_2.error_addr = 32'h0000_08F4;
        test_error_response();
        u_slave_bfm_2.error_inject_en = 1'b0;
        
        test_byte_halfword_access();
        test_reset_during_transfer();

        $display("\n========================================================");
        $display("   VERIFICATION COMPLETE");
        $display("   Passed: %0d", pass_count);
        $display("   Failed: %0d", fail_count);
        $display("========================================================\n");
        
        if (fail_count == 0 && pass_count > 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("ERROR: Some tests failed.");
        end

        $finish;
    end

    initial begin
        #100_000;
        $display("SIMULATION TIMEOUT!");
        $finish;
    end

    initial begin
        $dumpfile("system.vcd");
        $dumpvars(0, tb_ahb_lite_system);
    end

endmodule
