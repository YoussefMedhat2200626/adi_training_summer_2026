`timescale 1ns / 1ps
module spi_slave (
    // SPI Interface
    input  wire        CSB,
    input  wire        CLK,
    input  wire        SDI,
    output reg         SDO,
    // Register Map Interface
    output reg  [14:0] addr,
    output wire        wr_en,     // now combinational
    output wire [7:0]  wr_data,   // now combinational
    input  wire [7:0]  rd_data
);
    // Internal State Registers
    reg [3:0] bit_cnt;  // 4-bit counter for 0-15 (header) and 0-7 (data)
    reg       is_data;  // 0 = Header phase, 1 = Data phase
    reg       rw_bit;   // 0 = Write, 1 = Read

    // Shift register for SDI (write data being received) and SDO (read data)
    reg [7:0] wr_shift_reg;
    reg [7:0] rd_shift_reg;

    wire [7:0] wr_data_next = {wr_shift_reg[6:0], SDI};
    assign wr_data = wr_data_next;
    assign wr_en   = is_data && (bit_cnt == 4'd7) && (rw_bit == 1'b0);

    
    // Block 1: Input Sampling and Control (Rising Edge)
    
    always @(posedge CLK or posedge CSB) begin
        if (CSB) begin
            addr         <= 15'd0;
            wr_shift_reg <= 8'd0;
            rw_bit       <= 1'b0;
            bit_cnt      <= 4'd0;
            is_data      <= 1'b0;
        end else begin
            if (!is_data) begin
                // --- HEADER PHASE (16 clocks) ---
                if (bit_cnt == 4'd0) begin
                    rw_bit <= SDI;              // Bit 15: R/W flag
                end else begin
                    addr <= {addr[13:0], SDI};  // Bits 14:0: Shift in address
                end
                if (bit_cnt == 4'd15) begin
                    is_data <= 1'b1;
                    bit_cnt <= 4'd0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end else begin
                // --- DATA PHASE (8 clocks per byte) ---
                wr_shift_reg <= wr_data_next;
                if (bit_cnt == 4'd7) begin
                    // Whether it's a write (committed combinationally above)
                    // or a read, the address auto-increments for the next
                    // byte in a potential burst.
                    addr    <= addr + 1'b1;
                    bit_cnt <= 4'd0;
                end else begin
                    bit_cnt <= bit_cnt + 1'b1;
                end
            end
        end
    end

    
    // Block 2: Output Driving (Falling Edge)
    
    always @(negedge CLK or posedge CSB) begin
        if (CSB) begin
            SDO          <= 1'bz;
            rd_shift_reg <= 8'd0;
        end else if (rw_bit == 1'b1) begin
            if (is_data) begin
                if (bit_cnt == 4'd0) begin
                    // Half a clock cycle after the address updates, latch the combinational read data
                    SDO          <= rd_data[7];
                    rd_shift_reg <= {rd_data[6:0], 1'b0};
                end else begin
                    // Shift out the remaining 7 bits
                    SDO          <= rd_shift_reg[7];
                    rd_shift_reg <= {rd_shift_reg[6:0], 1'b0};
                end
            end else begin
                SDO <= 1'bz;
            end
        end else begin
            SDO <= 1'bz; // Remain Hi-Z during write mode
        end
    end
endmodule