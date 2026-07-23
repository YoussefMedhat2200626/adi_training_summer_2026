module regbank (Hclk, HRESTn, Haddr, Hwrite, Htrans, Hwdata, wait_cycles, force_error, Hready, Hresp, HRdata);
    input Hclk;
    input HRESTn;
    input [31:0] Haddr;
    input Hwrite;
    input [1:0]  Htrans;
    input [31:0] Hwdata;
    input [3:0]  wait_cycles;
    input  force_error;
    output Hready;          
    output Hresp;         
    output reg [31:0] HRdata;

    reg [31:0] regfile [0:15];
    reg [3:0]  count;       
    reg  in_wait;     
    reg  resp_err;    

    wire transfer_starting = (Htrans == 2'b10 || Htrans == 2'b11);

    assign Hready = in_wait ? (count == 0): (transfer_starting ? (wait_cycles == 0) : 1'b1);
    assign Hresp  = in_wait ? resp_err : (transfer_starting ? force_error : 1'b0);

    always @(posedge Hclk or negedge HRESTn) begin
        if (!HRESTn) begin
            in_wait  <= 1'b0;
            count    <= 0;
            resp_err <= 1'b0;
        end
        else begin
            if (in_wait) begin
                if (count == 0) begin
                    in_wait <= 1'b0;
                    if (!resp_err) begin
                        if (Hwrite) 
                          regfile[Haddr[5:2]] <= Hwdata;
                        else  
                          HRdata <= regfile[Haddr[5:2]];
                    end
                end
                else
                    count <= count - 1;
            end
            else if (transfer_starting) begin
                if (wait_cycles == 0) begin
                    if (!force_error) begin
                        if (Hwrite) 
                          regfile[Haddr[5:2]] <= Hwdata;
                        else        
                          HRdata <= regfile[Haddr[5:2]];
                    end
                end
                else begin
                    in_wait  <= 1'b1;
                    count <= wait_cycles - 1;
                    resp_err <= force_error;
                end
            end
        end
    end
endmodule