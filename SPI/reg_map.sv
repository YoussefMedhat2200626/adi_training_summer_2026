module reg_map #(
    parameter DATA_WIDTH = 8, ADDR_WIDTH = 15, DEPTH = 2**ADDR_WIDTH
) (
    input                     SCLK,
    input                     rst_n,
    input                     wr_en,
    input  [ADDR_WIDTH - 1:0] addr,
    input  [DATA_WIDTH - 1:0] wr_data,
    output [DATA_WIDTH - 1:0] rd_data
);
    

logic [DATA_WIDTH - 1:0] ram [DEPTH];

int offset;

assign rd_data = ram [addr];

always_ff @(posedge SCLK or negedge rst_n) begin
    if (!rst_n) begin
        for (int i=0; i<DEPTH; ++i) begin
            ram[i] <= 0;
        end
        offset <= 0;
    end
    else if (wr_en) begin
        ram[addr + offset] <= wr_data;
        offset <= offset + 1;
    end
end

endmodule