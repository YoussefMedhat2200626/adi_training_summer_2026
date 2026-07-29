import ahb_shared_pkg::*;
module ahb_slave(
    input                           HCLK,
    input                           HRESETn,
    input                           HSEL,
    input [ADDR_WIDTH - 1:0]        HADDR,
    input                           HWRITE,
    input size_e                    HSIZE,
    input burst_e                   HBURST,
    input transfer_e                HTRANS,
    input                           HREADY,
    input [DATA_WIDTH - 1:0]        HWDATA,

    output logic                    HREADYOUT,
    output logic                    HRESP,
    output logic [DATA_WIDTH - 1:0] HRDATA
    
);
assign HREADYOUT = HREADY;

logic [7:0] slave_mem [1024];
logic [ADDR_WIDTH - 1:0] addr_reg;

logic [1:0] error_flag;

always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        addr_reg <= 0;
    end
    else if (HSEL && HREADY)begin
        if ((HTRANS == NONSEQ || HTRANS == SEQ))
            addr_reg <= HADDR; 
    end
end


always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        HRDATA <= 0;
        for (int i=0; i<1024; ++i) begin
            slave_mem[i] <= 0;
        end
    end
    else if (HSEL && HREADY) begin
        if (((HTRANS == NONSEQ && HBURST == SINGLE) || HTRANS == SEQ)) begin
            if (HWRITE) begin
                for (int i=0; i<(1<<HSIZE); ++i) begin
                    slave_mem[addr_reg + i] <= HWDATA[(8*i) +: 8];
                end
            end else begin
                for (int i=0; i<(1<<HSIZE); ++i) begin
                    HRDATA[(8*i) +: 8] <= slave_mem[addr_reg + i];
                end
            end
        end
    end
end


always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        error_flag <= 0;
        HRESP <= 0;
    end
    else if (!HREADY) begin
        error_flag <= error_flag + 1;
        HRESP <= (error_flag == 1);
    end
    else HRESP <= 0;
end

endmodule