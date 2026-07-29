module spi_slave(
    input               SCLK,
    input               rst_n,
    input               CSB,
    input               SDI,
    output logic        SDO,
    output logic [14:0] addr,
    output logic [7:0]  wr_data,
    output logic        wr_en,
    input        [7:0]  rd_data
);

typedef enum bit [2:0] {IDLE,CHK_CMD,WRITE_ADDR,WRITE_DATA,READ_ADDR,READ_DATA} state_e;
state_e ps,ns;

logic CLK;
// IGC - Cell
logic en_latch;
always @* begin
    if (!SCLK)
        en_latch = ~CSB;
end

// Generate the gated clock
assign CLK = SCLK & en_latch;



logic [3:0] wr_addr_cnt,rd_addr_cnt;
logic [3:0] wr_data_cnt,rd_data_cnt;

logic [7:0] wr_data_reg;
logic [14:0] addr_reg;

always_ff @(negedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
       wr_addr_cnt <= 0;
    end
    else if (ps == IDLE) begin
        wr_addr_cnt <= 0;
    end
    else if (ps == WRITE_ADDR) begin
        wr_addr_cnt <= wr_addr_cnt + 1;
    end
end

always_ff @(negedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
       rd_addr_cnt <= 0;
    end
    else if (ps == IDLE) begin
        rd_addr_cnt <= 0;
    end
    else if (ps == READ_ADDR) begin
        rd_addr_cnt <= rd_addr_cnt + 1;
    end
end

always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
       wr_data_cnt <= 1;
    end
    else if (wr_data_cnt == 8) begin
        wr_data_cnt <= 1;
    end
    else if (ns == WRITE_DATA) begin
        wr_data_cnt <= wr_data_cnt + 1;
    end
end

always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
       rd_data_cnt <= 1;
    end
    else if (rd_data_cnt == 8) begin
        rd_data_cnt <= 1;
    end
    else if (ps == READ_DATA) begin
        rd_data_cnt <= rd_data_cnt + 1;
    end
end

always_ff @(posedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
        ps <= IDLE;
    end
    else begin
        ps <= ns;
    end
end

always_comb begin
    case (ps)
        IDLE: ns = (!CSB)? CHK_CMD : IDLE;
        CHK_CMD: begin
            if (!CSB) begin
                ns = (!SDI)? WRITE_ADDR : READ_ADDR;
            end else begin
                ns = IDLE;
            end
        end
        WRITE_ADDR: begin
            if (!CSB) begin
                ns = (wr_addr_cnt == 15)? WRITE_DATA: WRITE_ADDR;
            end else begin
                ns = IDLE;
            end
        end
        WRITE_DATA: begin
            if (!CSB) begin
                ns = WRITE_DATA;
            end else begin
                ns = IDLE;
            end
        end
        READ_ADDR: begin
            if (!CSB) begin
                ns = (rd_addr_cnt == 15)? READ_DATA : READ_ADDR;
            end else begin
                ns = IDLE;
            end
        end
        READ_DATA: begin
            if (!CSB) begin
                ns = READ_DATA;
            end else begin
                ns = IDLE;
            end
        end
    endcase
end

always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        wr_en <= 0;
    end
    else if (ps == WRITE_DATA && wr_data_cnt == 8) begin
        wr_en <= 1;
    end
    else begin
        wr_en <= 0;
    end
end

always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        addr_reg <= 0;
    end
    else if (ps == WRITE_ADDR) begin
        addr_reg[14 - wr_addr_cnt] <= SDI;
    end
end

always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        addr_reg <= 0;
    end
    else if (ps == READ_ADDR) begin
        addr_reg[14 - rd_addr_cnt] <= SDI;
    end
end

always_ff @(posedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        wr_data_reg <= 0;
    end
    else if (ns == WRITE_DATA) begin
        wr_data_reg[8 - wr_data_cnt] <= SDI;
    end
end
/*
always_ff @(negedge CLK or negedge rst_n) begin
    if (!rst_n) begin
        SDO <= 0;
    end
    else if (ns == READ_DATA) begin
        SDO <= rd_data[8 - rd_data_cnt];
    end 
end
*/
always_comb begin
    if (ns == READ_DATA) begin
        SDO = rd_data[8 - rd_data_cnt];
    end 
    else begin
        SDO = SDO;
    end
end

always_ff @(negedge CLK or negedge rst_n) begin
   if (!rst_n) begin
    wr_data <= 0;
   end else if (wr_data_cnt == 8) begin
    wr_data <= wr_data_reg;
   end 
end

assign addr = ((wr_addr_cnt == 15 && ps == WRITE_ADDR) || (rd_addr_cnt == 15 && ps == READ_ADDR))? addr_reg : addr;


    
endmodule