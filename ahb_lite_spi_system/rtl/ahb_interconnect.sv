

module ahb_interconnect
    import ahb_lite_pkg::*;
(

    input  logic                    HCLK,
    input  logic                    HRESETn,

    input  logic [ADDR_WIDTH-1:0]   HADDR,
    input  logic [DATA_WIDTH-1:0]   HWDATA,
    input  htrans_t                 HTRANS,
    input  logic                    HWRITE,
    input  hsize_t                  HSIZE,
    input  hburst_t                 HBURST,

    output logic [DATA_WIDTH-1:0]   HRDATA,
    output logic                    HREADY,
    output logic                    HRESP,

    output logic [ADDR_WIDTH-1:0]   HADDR_S,
    output logic [DATA_WIDTH-1:0]   HWDATA_S,
    output htrans_t                 HTRANS_S,
    output logic                    HWRITE_S,
    output hsize_t                  HSIZE_S,
    output hburst_t                 HBURST_S,
    output logic                    HREADY_S,     

    output logic                    HSEL_S0,
    output logic                    HSEL_S1,
    output logic                    HSEL_S2,

    input  logic [DATA_WIDTH-1:0]   HRDATA_S0,
    input  logic                    HREADYOUT_S0,
    input  logic                    HRESP_S0,

    input  logic [DATA_WIDTH-1:0]   HRDATA_S1,
    input  logic                    HREADYOUT_S1,
    input  logic                    HRESP_S1,

    input  logic [DATA_WIDTH-1:0]   HRDATA_S2,
    input  logic                    HREADYOUT_S2,
    input  logic                    HRESP_S2
);

    logic [NUM_SLAVES-1:0] hsel_dec;   

    ahb_decoder u_decoder (
        .HADDR  (HADDR),
        .HSEL   (hsel_dec)
    );

    ahb_mux u_mux (
        
        .HCLK        (HCLK),
        .HRESETn     (HRESETn),

        .HSEL        (hsel_dec),

        .HRDATA_0    (HRDATA_S0),
        .HREADYOUT_0 (HREADYOUT_S0),
        .HRESP_0     (HRESP_S0),

        .HRDATA_1    (HRDATA_S1),
        .HREADYOUT_1 (HREADYOUT_S1),
        .HRESP_1     (HRESP_S1),

        .HRDATA_2    (HRDATA_S2),
        .HREADYOUT_2 (HREADYOUT_S2),
        .HRESP_2     (HRESP_S2),

        .HRDATA      (HRDATA),
        .HREADY      (HREADY),
        .HRESP       (HRESP)
    );

    assign HADDR_S  = HADDR;
    assign HWDATA_S = HWDATA;
    assign HTRANS_S = HTRANS;
    assign HWRITE_S = HWRITE;
    assign HSIZE_S  = HSIZE;
    assign HBURST_S = HBURST;
    assign HREADY_S = HREADY;    

    assign HSEL_S0 = hsel_dec[0];
    assign HSEL_S1 = hsel_dec[1];
    assign HSEL_S2 = hsel_dec[2];

endmodule
