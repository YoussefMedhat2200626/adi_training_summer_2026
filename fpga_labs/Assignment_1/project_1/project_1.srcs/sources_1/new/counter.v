module counter(
    input clk,
    input rst_n,
    output reg [2:0] counter
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
    end else begin
        counter <= counter + 1'b1;
    end
end

endmodule