module spi_slave (CSB, SCLK, SDI, SDO, SDO_en, addr, wr_en, wr_data, rd_data);
    parameter int ADDR_WIDTH = 15;
    parameter int DATA_WIDTH = 8;

    input logic CSB;
    input logic SCLK;
    input logic SDI;
    output logic SDO;
    output logic SDO_en;

    output logic [ADDR_WIDTH - 1:0] addr;
    output logic wr_en;
    output logic [DATA_WIDTH - 1:0] wr_data;
    input logic [DATA_WIDTH - 1:0] rd_data;

    typedef enum logic [1:0] {IDLE = 2'b00, HEADER = 2'b01, WRITE = 2'b10, READ = 2'b11} state_t;

    state_t state;

    logic [3 : 0] cnt; 
    logic rw_reg;
    logic [ADDR_WIDTH - 1 : 0] addr_reg;
    logic [DATA_WIDTH - 2 : 0] wr_shift;

    always @(posedge SCLK or posedge CSB) begin
        if (CSB) begin
            state <= IDLE;
            cnt <= 4'b0;
            rw_reg <= 1'b0;
            addr_reg <= 15'b0;
            wr_shift <= 7'b0;
        end

        else begin
            case (state)
                IDLE: begin
                    rw_reg <= SDI;
                    addr_reg <= 15'b0;
                    cnt <= 4'd1;
                    state <= HEADER;
                end

                HEADER: begin
                    addr_reg <= {addr_reg[ADDR_WIDTH - 2 : 0], SDI};
                    if (cnt == 4'd15) begin
                        cnt <= 4'd0;
                        state <= (rw_reg) ? READ : WRITE;
                    end 
                    else begin
                        cnt <= cnt + 4'd1;
                    end
                end

                WRITE: begin
                    wr_shift <= {wr_shift[DATA_WIDTH - 3 : 0], SDI};
                    if (cnt == 4'd7) begin
                        cnt <= 4'd0;
                        addr_reg <= addr_reg + 1'b1;
                    end 
                    else begin
                        cnt <= cnt + 4'd1;
                    end
                end

                READ: begin
                    if (cnt == 4'd7) begin
                        cnt <= 4'd0;
                        addr_reg <= addr_reg + 1'b1;
                    end else begin
                        cnt <= cnt + 4'd1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

    always @(negedge SCLK or posedge CSB) begin
        if (CSB) begin
            SDO_en <= 1'b0;
            SDO <= 1'b0;
        end else if (state == READ) begin
            SDO_en <= 1'b1;
            SDO <= rd_data[DATA_WIDTH - 1 - cnt];
        end else begin
            SDO_en <= 1'b0;
        end
    end

    assign wr_en = (!CSB) && (state == WRITE) && (cnt == 4'd7);
    assign wr_data = {wr_shift[DATA_WIDTH - 2 : 0], SDI};
    assign addr = addr_reg;

endmodule