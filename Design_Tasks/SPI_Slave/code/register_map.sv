module register_map #(
parameter DATA_WIDTH = 8,
parameter ADDR_WIDTH = 15,           
parameter DEPTH = (1<<ADDR_WIDTH) 
)(
input  clk,wr_en,
input  [ADDR_WIDTH-1:0] addr,
input  [DATA_WIDTH-1:0] wr_data,
output [DATA_WIDTH-1:0] rd_data
);
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(negedge clk) begin
    if (wr_en) begin
    mem[addr] <= wr_data;
    end
end
//combinational read
assign rd_data = mem[addr];
endmodule