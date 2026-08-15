module register_map (
    input  logic        clk,
    input  logic [14:0] addr,
    input  logic         wr_en,
    input  logic [7:0]   wr_data,
    output logic [7:0]   rd_data
);

    logic [7:0] mem [0:32767];

    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= wr_data;
        end
    end

    assign rd_data = mem[addr];

endmodule