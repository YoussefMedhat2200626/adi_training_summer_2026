`timescale 1ns / 1ps

module counter3bit (
    input wire clk,   // 1 Hz clock input
    input wire rst,   // Active high reset
    output reg [2:0] count // 3-bit counter output for LEDs
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 3'b000;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
