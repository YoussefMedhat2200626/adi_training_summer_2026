module ahb_decoder (
    input  logic [31:0] HADDR,

    output logic HSEL0,
    output logic HSEL1
);

always_comb begin
   
    HSEL0 = 1'b0;
    HSEL1 = 1'b0;



    if (HADDR >= 32'h0000_0000 && HADDR <= 32'h0000_03FF)
        HSEL0 = 1'b1;

    else if (HADDR >= 32'h0000_0400 && HADDR <= 32'h0000_07FF)
        HSEL1 = 1'b1;
end

endmodule