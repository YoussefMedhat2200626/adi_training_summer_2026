
module clk_div(
    input wire       ref_clk, // 8 MHZ
    input wire       rst_n,
    output wire      divided_clk
    );
    
    reg [31:0]div_ratio = 'd8;
    reg       divided_clk_temp;
    reg [6:0] counter;
    reg       flag;    // is used to detect if clk now is 0 or 1 [don't directly connect output of FF to FF input (back in DFT)] 
    always@(posedge ref_clk or negedge rst_n)
    begin
        if(~rst_n) begin 
            counter <= 0;
            flag <= 0;
            divided_clk_temp <= 0; end
        else if((div_ratio[0] == 0) && (counter == (div_ratio>>1) - 1) )  //even [toggle every div_ratio/2]
                // div_ratio = 8 (for output 1MHz) ,div_ratio = 8*10^6 (for output 1Hz) 
                begin
                divided_clk_temp <= ~divided_clk_temp;
                counter <= 0;
                end
        else if((div_ratio[0] == 1) && (( flag && (counter == (div_ratio>>1) - 1) || (!flag && counter == (div_ratio>>1)))) ) //odd 
                begin
                divided_clk_temp <= ~divided_clk_temp;
                flag <= ~flag;
                counter <= 0;
                end
        else counter <= counter + 1;
    end
    
    assign divided_clk = (div_ratio == 1 || div_ratio == 0)? ref_clk : divided_clk_temp;    
endmodule
