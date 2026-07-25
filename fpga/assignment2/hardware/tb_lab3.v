`timescale 1ns / 1ps

module tb_lab3();

    // Inputs to the wrapper
    reg in_0;
    reg in_1;
    
    // Output from the wrapper
    wire [0:0] nor_out_tri_o;

    // inout ports (wires)
    wire [14:0] DDR_addr;
    wire [2:0] DDR_ba;
    wire DDR_cas_n;
    wire DDR_ck_n;
    wire DDR_ck_p;
    wire DDR_cke;
    wire DDR_cs_n;
    wire [3:0] DDR_dm;
    wire [31:0] DDR_dq;
    wire [3:0] DDR_dqs_n;
    wire [3:0] DDR_dqs_p;
    wire DDR_odt;
    wire DDR_ras_n;
    wire DDR_reset_n;
    wire DDR_we_n;
    wire FIXED_IO_ddr_vrn;
    wire FIXED_IO_ddr_vrp;
    wire [53:0] FIXED_IO_mio;
    wire FIXED_IO_ps_clk;
    wire FIXED_IO_ps_porb;
    wire FIXED_IO_ps_srstb;

    // Instantiate the wrapper
    nor_zynq_sys_wrapper uut (
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .in_0(in_0),
        .in_1(in_1),
        .nor_out_tri_o(nor_out_tri_o)
    );

    // Provide a dummy clock and reset to the inouts if needed (using pullup/pulldown or force)
    reg clk_reg = 0;
    always #10 clk_reg = ~clk_reg;
    assign FIXED_IO_ps_clk = clk_reg;
    
    reg reset_reg = 0;
    assign FIXED_IO_ps_porb = reset_reg;
    assign FIXED_IO_ps_srstb = reset_reg;

    // Stimulus process
    initial begin
        // Initial setup and reset
        reset_reg = 0;
        in_0 = 0;
        in_1 = 0;
        
        #100;
        reset_reg = 1;
        
        // Wait some time for system to initialize
        #200;
        
        // Apply test vectors for logic verification
        // 0 0
        in_0 = 0; in_1 = 0;
        #1000;
        
        // 0 1
        in_0 = 0; in_1 = 1;
        #1000;
        
        // 1 0
        in_0 = 1; in_1 = 0;
        #1000;
        
        // 1 1
        in_0 = 1; in_1 = 1;
        #1000;

        $display("Simulation Finished!");
        $finish;
    end

    initial begin
        $monitor("Time = %0t | in_0 = %b | in_1 = %b | nor_out_tri_o = %b", $time, in_0, in_1, nor_out_tri_o);
    end

endmodule
