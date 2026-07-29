module Single_port_Async_RAM #(
    parameter MEM_DEPTH   = 32768,
    parameter ADDR_WIDTH  = 15,
    parameter DATA_WIDTH  = 8
)(
    input  logic                    sclk,
    input  logic                    rst_n,

    input  logic [ADDR_WIDTH-1:0]   addr,
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1:0]   wr_data,

    output logic [DATA_WIDTH-1:0]   rd_data
);

logic [DATA_WIDTH-1:0] RAM [0:MEM_DEPTH-1];

// Combinational read
assign rd_data = (rst_n)? RAM[addr] : 0;

// Synchronous write
always_ff @(posedge sclk) begin
    if (wr_en)
        RAM[addr] <= wr_data;
end

endmodule