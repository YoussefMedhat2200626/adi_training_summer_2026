module reg_map (clk, wr_en, addr, wr_data, rd_data);
    parameter int ADDR_WIDTH = 15;
    parameter int DATA_WIDTH = 8;
    parameter int DEPTH  = 32768;

    input logic clk;
    input logic wr_en;
    input logic [ADDR_WIDTH - 1 : 0] addr;
    input logic [DATA_WIDTH - 1 : 0] wr_data;
    output logic [DATA_WIDTH - 1 : 0] rd_data;

    logic [DATA_WIDTH - 1 : 0] mem [DEPTH - 1 : 0];

    always @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= wr_data;
        end
    end

    assign rd_data = mem[addr];

endmodule