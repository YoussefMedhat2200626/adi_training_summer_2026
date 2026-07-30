`timescale 1ns / 1ps

module spi_slave (
    input  wire        sclk,
    input  wire        csb,
    input  wire        sdi,
    output wire        sdo,
    output reg         wr_en,
    output reg  [14:0] addr,
    output reg  [7:0]  wr_data,
    input  wire [7:0]  rd_data
);

    // FSM States
    localparam IDLE       = 2'b00;
    localparam HEADER     = 2'b01;
    localparam DATA_WRITE = 2'b10;
    localparam DATA_READ  = 2'b11;

    reg [1:0] state;
    reg [3:0] bit_cnt;
    reg       rw_bit;

    // SDO tri-state control registers
    reg sdo_reg;
    reg sdo_oe;

    // =========================================================================
    // Main SPI State Machine (Sample on Rising Edge)
    // =========================================================================
    always @(posedge sclk or posedge csb) begin
        if (csb) begin
            state   <= IDLE;
            bit_cnt <= 4'd15;
            addr    <= 15'd0;
            wr_data <= 8'd0;
            wr_en   <= 1'b0;
            rw_bit  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    state   <= HEADER;
                    bit_cnt <= 4'd14; // We are processing the 15th bit now
                    rw_bit  <= sdi;   // Bit 15 is R/W
                    wr_en   <= 1'b0;
                end

                HEADER: begin
                    addr <= {addr[13:0], sdi};
                    if (bit_cnt > 0) begin
                        bit_cnt <= bit_cnt - 1;
                    end else begin
                        bit_cnt <= 4'd7;
                        state   <= rw_bit ? DATA_READ : DATA_WRITE;
                    end
                end

                DATA_WRITE: begin
                    wr_data <= {wr_data[6:0], sdi};
                    
                    if (bit_cnt > 0) begin
                        bit_cnt <= bit_cnt - 1;
                    end else begin
                        bit_cnt <= 4'd7;
                        wr_en   <= 1'b1; // Trigger a write pulse
                    end

                    // De-assert wr_en and increment address on the cycle 
                    // AFTER bit_cnt was 0 (beginning of next byte in burst)
                    if (wr_en) begin
                        wr_en <= 1'b0;
                        addr  <= addr + 1;
                    end
                end

                DATA_READ: begin
                    if (bit_cnt > 0) begin
                        bit_cnt <= bit_cnt - 1;
                    end else begin
                        bit_cnt <= 4'd7;
                        addr    <= addr + 1; // Increment address for next byte
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // =========================================================================
    // SDO Drive Logic (Drive on Falling Edge)
    // =========================================================================
    always @(negedge sclk or posedge csb) begin
        if (csb) begin
            sdo_oe  <= 1'b0;
            sdo_reg <= 1'b0;
        end else begin
            if (state == DATA_READ) begin
                sdo_oe  <= 1'b1;
                sdo_reg <= rd_data[bit_cnt];
            end else begin
                sdo_oe  <= 1'b0;
            end
        end
    end

    // Tri-state buffer
    assign sdo = sdo_oe ? sdo_reg : 1'bz;

endmodule