module spi_slave (
    input  logic        rst_n,   
    input  logic        csb,     
    input  logic        sclk,    
    input  logic        sdi,     
    output logic        sdo,     

    output logic [14:0] addr,
    output logic        wr_en,
    output logic [7:0]  wr_data,
    input  logic [7:0]  rd_data
);


    typedef enum logic [1:0] {
        IDLE    = 2'd0,
        HEADER  = 2'd1,
        WR_BYTE = 2'd2,
        RD_BYTE = 2'd3
    } state_t;

    state_t      state;
    logic [3:0]  bit_cnt;     
    logic        rw_bit;      
    logic [14:0] addr_reg;    
    logic [7:0]  data_shift;  


    always_ff @(posedge sclk or posedge csb or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            bit_cnt    <= '0;
            rw_bit     <= 1'b0;
            addr_reg   <= '0;
            data_shift <= '0;
        end else if (csb) begin
            state   <= IDLE;
            bit_cnt <= '0;
        end else begin
            case (state)
                IDLE: begin
                    rw_bit  <= sdi;
                    bit_cnt <= 4'd0;
                    state   <= HEADER;
                end

                HEADER: begin
                    addr_reg <= {addr_reg[13:0], sdi};
                    if (bit_cnt == 4'd14) begin
                        bit_cnt <= 4'd0;
                        state   <= rw_bit ? RD_BYTE : WR_BYTE;
                    end else begin
                        bit_cnt <= bit_cnt + 4'd1;
                    end
                end

                WR_BYTE: begin
                    data_shift <= {data_shift[6:0], sdi};
                    if (bit_cnt == 4'd7) begin
                        addr_reg <= addr_reg + 15'd1;
                        bit_cnt  <= 4'd0;
                        state    <= WR_BYTE;
                    end else begin
                        bit_cnt <= bit_cnt + 4'd1;
                    end
                end

                RD_BYTE: begin
                    if (bit_cnt == 4'd7) begin
                        addr_reg <= addr_reg + 15'd1;
                        bit_cnt  <= 4'd0;
                        state    <= RD_BYTE;
                    end else begin
                        bit_cnt <= bit_cnt + 4'd1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    assign addr    = addr_reg;
    assign wr_en   = (state == WR_BYTE) && (bit_cnt == 4'd7);
    assign wr_data = {data_shift[6:0], sdi};

    logic [7:0] rd_byte;

    always_ff @(negedge sclk or posedge csb or negedge rst_n) begin
        if (!rst_n || csb) begin
            sdo     <= 1'bz;
            rd_byte <= 8'h00;
        end else if (state == RD_BYTE) begin
            if (bit_cnt == 4'd0) begin
                rd_byte <= rd_data;      
                sdo     <= rd_data[7];   
            end else begin
                rd_byte <= {rd_byte[6:0], 1'b0};
                sdo     <= rd_byte[6];
            end
        end else begin
            sdo <= 1'bz;                 
        end
    end

endmodule