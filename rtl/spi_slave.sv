`timescale 1ns/1ps

module spi_slave (
    input  logic rst_n,
    
    input  logic SCLK,
    input  logic MOSI,
    output logic MISO,
    input  logic CSn
);

    logic [4:0] bit_cnt;      
    logic [7:0] cmd_addr_reg; 
    logic [7:0] data_reg;     

    logic       reg_wr_en;
    logic [6:0] reg_addr;
    logic [7:0] reg_wdata;
    logic [7:0] reg_rdata;

    logic miso_out;
    assign MISO = (!CSn) ? miso_out : 1'bz;

    always_ff @(posedge SCLK or posedge CSn) begin
        if (CSn) begin
            bit_cnt      <= 5'd0;
            cmd_addr_reg <= 8'h00;
            data_reg     <= 8'h00;
        end else begin
            
            if (bit_cnt < 5'd8) begin
                cmd_addr_reg <= {cmd_addr_reg[6:0], MOSI};
            end else if (bit_cnt < 5'd16) begin
                data_reg <= {data_reg[6:0], MOSI};
            end

            if (bit_cnt < 5'd16) begin
                bit_cnt <= bit_cnt + 1'b1;
            end
        end
    end

    assign reg_wr_en = (bit_cnt == 5'd16) && (cmd_addr_reg[7] == 1'b1);
    
    assign reg_addr  = cmd_addr_reg[6:0];
    assign reg_wdata = data_reg;

    spi_reg_map u_reg_map (
        .clk(SCLK), 
        .rst_n(rst_n),
        .addr(reg_addr),
        .wr_en(reg_wr_en),
        .wdata(reg_wdata),
        .rdata(reg_rdata)
    );

    logic [7:0] tx_shift_reg;

    always_ff @(negedge SCLK or posedge CSn) begin
        if (CSn) begin
            tx_shift_reg <= 8'h00;
            miso_out     <= 1'b0; 
        end else begin
            if (bit_cnt == 5'd8) begin

                if (cmd_addr_reg[7] == 1'b0) begin
                    tx_shift_reg <= {reg_rdata[6:0], 1'b0};
                    miso_out     <= reg_rdata[7];
                end else begin
                    miso_out     <= 1'b0;
                end
            end else if (bit_cnt > 5'd8 && bit_cnt < 5'd16) begin
                
                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                miso_out     <= tx_shift_reg[7];
            end else begin
                miso_out     <= 1'b0; 
            end
        end
    end

endmodule
