

module ahb_decoder
    import ahb_lite_pkg::*;
(
        
        input  logic [ADDR_WIDTH-1:0]  HADDR,

        output logic [NUM_SLAVES-1:0]  HSEL
);

    always_comb begin
        
        HSEL = '0;

        case (HADDR[11:10])
            2'b00:   HSEL[0] = 1'b1;   
            2'b01:   HSEL[1] = 1'b1;   
            2'b10:   HSEL[2] = 1'b1;   
            default: HSEL    = '0;     
        endcase
    end

endmodule
