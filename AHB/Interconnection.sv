module ahb_interconnect #(
    parameter MEM_BASE_ADDR      = 32'h0000_0000,
    parameter MEM_SIZE_PER_SLAVE = 1024 // 1KB Per Slave
)(
    input  logic        hclk,
    input  logic        hresetn,

    // Decoder inputs
    input  logic [31:0] haddr,
    input  logic [1:0]  htrans,

    // MUX inputs
    input  logic [31:0] hrdata_s0, hrdata_s1, hrdata_s2,
    input  logic        hready_out_s0, hready_out_s1, hready_out_s2,
    input  logic        hresp_s0, hresp_s1, hresp_s2,

    // Decoder outputs to slaves
    output logic        hsel_s0, hsel_s1, hsel_s2,

    // MUX outputs to master
    output logic [31:0] hrdata,
    output logic        hready,
    output logic        hresp
);

    // HTRANS Encoding
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;
    localparam logic [1:0] HTRANS_SEQ    = 2'b11;

    // Address Decoder (Address Phase)
    always_comb begin
        hsel_s0 = 1'b0;
        hsel_s1 = 1'b0;
        hsel_s2 = 1'b0;
            
        if (haddr >= MEM_BASE_ADDR && haddr < MEM_BASE_ADDR + MEM_SIZE_PER_SLAVE)
            hsel_s0 = 1'b1;
        else if (haddr >= MEM_BASE_ADDR + MEM_SIZE_PER_SLAVE && haddr < MEM_BASE_ADDR + 2*MEM_SIZE_PER_SLAVE)
            hsel_s1 = 1'b1;
        else if (haddr >= MEM_BASE_ADDR + 2*MEM_SIZE_PER_SLAVE && haddr < MEM_BASE_ADDR + 3*MEM_SIZE_PER_SLAVE)
            hsel_s2 = 1'b1;
    end

    // Pipelining
    logic reg_sel_s0, reg_sel_s1, reg_sel_s2;
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            reg_sel_s0 <= 1'b0;
            reg_sel_s1 <= 1'b0;
            reg_sel_s2 <= 1'b0;
        end else if (hready) begin 
            if(htrans == HTRANS_NONSEQ || htrans == HTRANS_SEQ) begin
                reg_sel_s0 <= hsel_s0;
                reg_sel_s1 <= hsel_s1;
                reg_sel_s2 <= hsel_s2;
            end else begin
                reg_sel_s0 <= 1'b0;
                reg_sel_s1 <= 1'b0;
                reg_sel_s2 <= 1'b0;
            end
        end
    end

    // Data Phase MUX
    always_comb begin
        case ({reg_sel_s2, reg_sel_s1, reg_sel_s0})
            3'b001: begin
                hrdata = hrdata_s0;
                hready = hready_out_s0;
                hresp  = hresp_s0;
            end
            3'b010: begin
                hrdata = hrdata_s1;
                hready = hready_out_s1;
                hresp  = hresp_s1;
            end
            3'b100: begin
                hrdata = hrdata_s2;
                hready = hready_out_s2;
                hresp  = hresp_s2;
            end
            default: begin
                hrdata = 32'd0;
                hready = 1'b1; // Default to ready if no slave is in data phase
                hresp  = 1'b0; // Default to OKAY 
            end
        endcase
    end
endmodule