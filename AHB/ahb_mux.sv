module ahb_mux (
    input  logic        HCLK,
    input  logic        HRESETn,

    // Global ready from previous transfer
    input  logic        HREADY,

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

logic sel0_reg, sel1_reg;

////////////////////////////////////////////////////////////
// Latch selected slave only when a new transfer is accepted
////////////////////////////////////////////////////////////
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        sel0_reg <= 1'b0;
        sel1_reg <= 1'b0;
    end
    else if (HREADY) begin
        sel0_reg <= HSEL0;
        sel1_reg <= HSEL1;
    end
end

////////////////////////////////////////////////////////////
// Response Multiplexer
////////////////////////////////////////////////////////////
always_comb begin

    // Default values
    HRDATA    = 32'h00000000;
    HREADYOUT = 1'b1;
    HRESP     = 1'b0;

    if (sel0_reg) begin
        HRDATA    = HRDATA0;
        HREADYOUT = HREADYOUT0;
        HRESP     = HRESP0;
    end
    else if (sel1_reg) begin
        HRDATA    = HRDATA1;
        HREADYOUT = HREADYOUT1;
        HRESP     = HRESP1;
    end

end

endmodule