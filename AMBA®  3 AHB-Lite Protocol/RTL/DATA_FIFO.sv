module DATA_FIFO (clk, rst, wr_en, wr_data, rd_en, rd_data, empty, full);
    parameter WIDTH = 32;  // Data width (bits per word)
    parameter DEPTH = 16;  // FIFO depth (number of words)
    parameter ADDR_SIZE = 4;  // Address size (log2(DEPTH))

    input clk, rst, wr_en, rd_en;
    input [WIDTH - 1 : 0] wr_data;
    output empty, full;
    output reg [WIDTH - 1 : 0] rd_data;

    reg [WIDTH - 1 : 0] fifo [DEPTH - 1 : 0];

    // Write and read pointers (extra bit used to detect full/empty)
    reg [ADDR_SIZE : 0] wr_ptr, rd_ptr;
    
    // Full condition:
    // FIFO is full when MSBs of wr_ptr and rd_ptr differ
    // and their lower bits are equal
    assign full = (wr_ptr[ADDR_SIZE] != rd_ptr[ADDR_SIZE]) && (wr_ptr[ADDR_SIZE - 1 : 0] == rd_ptr[ADDR_SIZE - 1 : 0])? 1 : 0;

    // Empty condition:
    // FIFO is empty when write and read pointers are equal
    assign empty = (wr_ptr == rd_ptr)? 1 : 0;

    always @ (posedge clk) begin
        if (!rst) begin
            rd_data <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end
        
        else begin
            if (wr_en && (full != 1'b1)) begin
                wr_ptr <= wr_ptr + 1;  // Move write pointer
                fifo[wr_ptr[ADDR_SIZE - 1 : 0]] <= wr_data;  // Store data in FIFO
            end
            if (rd_en && (empty != 1'b1)) begin
                rd_ptr <= rd_ptr + 1;  // Move read pointer
                rd_data <= fifo[rd_ptr[ADDR_SIZE - 1 : 0]];  // Read data from FIFO
            end
        end

    end
endmodule