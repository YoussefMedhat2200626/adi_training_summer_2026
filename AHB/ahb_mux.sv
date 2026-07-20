module ahb_mux (


    // Current decoder outputs
    input  logic        HSEL0,
    input  logic        HSEL1,

    // Slave 0 response
    input  logic [31:0] HRDATA0,
    input  logic        HREADYOUT0,
    input  logic        HRESP0,

    // Slave 1 response
    input  logic [31:0] HRDATA1,
    input  logic        HREADYOUT1,
    input  logic        HRESP1,

    // Bus outputs
    output logic [31:0] HRDATA,
    output logic        HREADYOUT,
    output logic        HRESP
);

always_comb begin

    // Default values
    HRDATA    = 32'h00000000;
    HREADYOUT = 1'b1;
    HRESP     = 1'b0;

    if (HSEL0) begin
        HRDATA    = HRDATA0;
        HREADYOUT = HREADYOUT0;
        HRESP     = HRESP0;
    end
    else if (HSEL1) begin
        HRDATA    = HRDATA1;
        HREADYOUT = HREADYOUT1;
        HRESP     = HRESP1;
    end

end

endmodule