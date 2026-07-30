`timescale 1ns / 1ps

module register_map (
    input  wire        clk,
    input  wire        wr_en,
    input  wire [14:0] addr,
    input  wire [7:0]  wr_data,
    output wire [7:0]  rd_data
);

    // 32768 x 8-bit memory
    reg [7:0] memory [0:32767];
    
    integer i;
    initial begin
        for (i = 0; i < 32768; i = i + 1) begin
            memory[i] = 8'h00;
        end
    end

    // Combinational read path - mandatory for SPI 0.5 cycle turnaround
    assign rd_data = memory[addr];

    // Synchronous write
    // Writing on the negative edge ensures the last byte of an SPI transaction
    // is safely written into memory before CSB goes high.
    always @(negedge clk) begin
        if (wr_en) begin
            memory[addr] <= wr_data;
        end
    end

endmodule