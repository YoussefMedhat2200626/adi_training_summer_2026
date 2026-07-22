module clock_div #(parameter  WIDTH =16)
( input clk_in,
  input rst_n,
  input [WIDTH-1:0] divisor,
  output reg clk_out 
);
 reg [WIDTH-1:0] counter;
 always @(posedge clk_in or negedge rst_n) begin
    if(!rst_n) begin
        clk_out <= 0;
        counter <= 0;
    end
    else if(counter == divisor -1) begin
           counter <= 0;
           clk_out <= ~clk_out; 
    end       
    else
           counter <= counter +1; 
 end

endmodule