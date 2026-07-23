`timescale 1ns/1ps

module spi_reg_map (
    input  logic       clk,      
    input  logic       rst_n,
    input  logic [6:0] addr,
    input  logic       wr_en,
    input  logic [7:0] wdata,
    output logic [7:0] rdata
);

    logic [7:0] registers [0:3];

    always_comb begin
        if (addr < 7'd4) begin
            case (addr[1:0])
                2'd0: rdata = registers[0];
                2'd1: rdata = registers[1];
                2'd2: rdata = registers[2];
                2'd3: rdata = registers[3];
            endcase
        end else begin
            rdata = 8'h00;
        end
    end

    always_ff @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            registers[0] <= 8'h00;
            registers[1] <= 8'h00;
            registers[2] <= 8'h00;
            registers[3] <= 8'h00;
        end else if (wr_en) begin
            if (addr < 7'd4) begin
                registers[addr[1:0]] <= wdata;
            end
        end
    end

endmodule
