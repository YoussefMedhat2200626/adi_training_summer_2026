`timescale 1ns/1ps

module ahb_lite_slave #(
    parameter MEM_SIZE = 256
)(
    input  wire        HCLK,
    input  wire        HRESETn,
    
    // --- New Signal to force wait states ---
    input  wire        force_wait, 

    // --- AHB-Lite Slave Bus Interface ---
    input  wire [31:0] HADDR,
    input  wire [1:0]  HTRANS,
    input  wire        HWRITE,
    input  wire [2:0]  HSIZE,
    input  wire [31:0] HWDATA,
    input  wire        HREADY,      

    output wire [31:0] HRDATA,
    output wire        HREADYOUT,  
    output wire        HRESP       
);

    reg [31:0] mem [0:MEM_SIZE-1];
    reg [31:0] addr_q;
    reg        write_q;
    reg        valid_q;

    wire trans_valid = (HTRANS == 2'b10 || HTRANS == 2'b11);

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_q  <= 32'd0;
            write_q <= 1'b0;
            valid_q <= 1'b0;
        end else if (HREADY) begin // Slave freezes internal state if HREADY is low
            addr_q  <= HADDR;
            write_q <= HWRITE;
            valid_q <= trans_valid; 
        end
    end

    always @(posedge HCLK) begin
        // Memory write ONLY occurs when the data phase is un-stalled (HREADY high)
        if (valid_q && write_q && HREADY) begin 
            mem[addr_q[9:2]] <= HWDATA;
        end
    end

    assign HRDATA = (valid_q && !write_q) ? mem[addr_q[9:2]] : 32'd0;
    
    // HREADYOUT is normally 1, but drops to 0 when forced by the testbench
    assign HREADYOUT = ~force_wait; 
    assign HRESP     = 1'b0;

endmodule