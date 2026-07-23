module fifo (
    input clk,
    input reset,
    input write_en,
    input read_en,
    input [31:0] din,          // fixed 32-bit input
    output [31:0] dout,        // fixed 32-bit output
    output full,
    output empty
);

    // Fixed depth = 4
    reg [31:0] memory [0:3];   // storage memory

    // Pointers sized for 4 entries
    reg [1:0] write_pointer = 0, read_pointer = 0; // 2 bits for 0..3
    reg [2:0] data_count = 0; // counts up to 4

    always @(posedge clk) begin
        if (!reset) begin
            write_pointer <= 0;
            read_pointer  <= 0;
            data_count    <= 0;
        end else begin
            if (write_en && !full) begin
                memory[write_pointer] <= din;
                write_pointer <= write_pointer + 1;
                data_count    <= data_count + 1;
            end
            if (read_en && !empty) begin
                read_pointer <= read_pointer + 1;
                data_count   <= data_count - 1;
            end
        end
    end

    // flag logic
    assign empty = (data_count == 0);
    assign full  = (data_count == 4);

    // output logic
    assign dout = memory[read_pointer]; // fall-through read

endmodule
