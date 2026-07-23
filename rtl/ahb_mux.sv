

module ahb_mux
    import ahb_lite_pkg::*;
(
        
        input  logic                    HCLK,
    input  logic                    HRESETn,

        input  logic [NUM_SLAVES-1:0]   HSEL,

    input  logic [DATA_WIDTH-1:0]   HRDATA_0,
    input  logic                    HREADYOUT_0,
    input  logic                    HRESP_0,

    input  logic [DATA_WIDTH-1:0]   HRDATA_1,
    input  logic                    HREADYOUT_1,
    input  logic                    HRESP_1,

    input  logic [DATA_WIDTH-1:0]   HRDATA_2,
    input  logic                    HREADYOUT_2,
    input  logic                    HRESP_2,

        output logic [DATA_WIDTH-1:0]   HRDATA,
    output logic                    HREADY,
    output logic                    HRESP
);

    logic [NUM_SLAVES-1:0] hsel_reg;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            hsel_reg <= '0;
        end else if (HREADY) begin
            hsel_reg <= HSEL;
        end
    end

    always_comb begin
        
        HRDATA = '0;
        HREADY = 1'b1;
        HRESP  = 1'b0;   

        if (hsel_reg[0]) begin
            HRDATA = HRDATA_0;
            HREADY = HREADYOUT_0;
            HRESP  = HRESP_0;
        end else if (hsel_reg[1]) begin
            HRDATA = HRDATA_1;
            HREADY = HREADYOUT_1;
            HRESP  = HRESP_1;
        end else if (hsel_reg[2]) begin
            HRDATA = HRDATA_2;
            HREADY = HREADYOUT_2;
            HRESP  = HRESP_2;
        end
        
    end

endmodule
