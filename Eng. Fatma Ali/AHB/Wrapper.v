`timescale 1ns/1ps

module ahb_system_top (
    input  wire        HCLK,
    input  wire        HRESETn,
    
    // --- User Command Interface ---
    input  wire        cmd_valid,
    input  wire [31:0] cmd_addr,
    input  wire        cmd_write,
    input  wire [2:0]  cmd_size,
    input  wire [2:0]  cmd_burst,
    input  wire        cmd_lock,
    input  wire [31:0] cmd_wdata,
    input  wire        cmd_busy,
    output wire        cmd_ready,
    
    // --- Testbench Control ---
    input  wire        slv_force_wait
);

    wire [31:0] ahb_haddr;
    wire [31:0] ahb_hwdata;
    wire [31:0] ahb_hrdata;
    wire [2:0]  ahb_hsize;
    wire [2:0]  ahb_hburst;
    wire [1:0]  ahb_htrans;
    wire        ahb_hwrite;
    wire        ahb_hmastlock;
    wire        ahb_hready;
    wire        ahb_hresp;

    ahb_lite_master u_master (
        .HCLK      (HCLK),
        .HRESETn   (HRESETn),
        .cmd_valid (cmd_valid),
        .cmd_addr  (cmd_addr),
        .cmd_write (cmd_write),
        .cmd_size  (cmd_size),
        .cmd_burst (cmd_burst),
        .cmd_lock  (cmd_lock),
        .cmd_wdata (cmd_wdata),
        .cmd_busy  (cmd_busy),
        .cmd_ready (cmd_ready),
        .HADDR     (ahb_haddr),
        .HWRITE    (ahb_hwrite),
        .HSIZE     (ahb_hsize),
        .HBURST    (ahb_hburst),
        .HTRANS    (ahb_htrans),
        .HMASTLOCK (ahb_hmastlock),
        .HWDATA    (ahb_hwdata),
        .HRDATA    (ahb_hrdata),
        .HREADY    (ahb_hready),
        .HRESP     (ahb_hresp)
    );

    ahb_lite_slave #(
        .MEM_SIZE  (256)
    ) u_slave (
        .HCLK      (HCLK),
        .HRESETn   (HRESETn),
        .force_wait(slv_force_wait), 
        .HADDR     (ahb_haddr),
        .HTRANS    (ahb_htrans),
        .HWRITE    (ahb_hwrite),
        .HSIZE     (ahb_hsize),
        .HWDATA    (ahb_hwdata),
        .HREADY    (ahb_hready),
        .HRDATA    (ahb_hrdata),
        .HREADYOUT (ahb_hready),
        .HRESP     (ahb_hresp)
    );
endmodule