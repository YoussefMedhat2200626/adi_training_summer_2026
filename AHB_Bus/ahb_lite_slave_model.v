module ahb_lite_slave_model #(
    parameter AW      = 32,
    parameter DW      = 32,
    parameter MEM_WDS = 64
) (
    input  wire            HCLK,
    input  wire            HRESETn,

    input  wire             HSEL,
    input  wire [AW-1:0]    HADDR,
    input  wire             HWRITE,
    input  wire [1:0]       HTRANS,
    input  wire [DW-1:0]    HWDATA,
    input  wire             HREADY,    

    output reg               HREADYOUT,
    output reg               HRESP,
    output reg  [DW-1:0]     HRDATA,

    
    input  wire [3:0]        wait_states  
);

    reg [DW-1:0] mem [0:MEM_WDS-1];

    
    reg             ap_write;
    reg [AW-1:0]    ap_addr;
    reg             ap_active;
    reg [3:0]       wait_cnt;
    reg             ap_err;
    reg             err_2nd_cycle;

    wire sel_valid = HSEL && HREADY && (HTRANS == 2'b10 || HTRANS == 2'b11);
    
    
    wire is_err_addr = (HADDR[31:16] == 16'hDEAD);

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            HREADYOUT     <= 1'b1;
            HRESP         <= 1'b0;
            ap_active     <= 1'b0;
            ap_err        <= 1'b0;
            err_2nd_cycle <= 1'b0;
            wait_cnt      <= 4'd0;
        end else begin

        
            if (ap_active) begin
                if (ap_err) begin
                    if (!err_2nd_cycle) begin
                        HREADYOUT     <= 1'b0;
                        HRESP         <= 1'b1;
                        err_2nd_cycle <= 1'b1;
                    end else begin
                        HREADYOUT     <= 1'b1;
                        HRESP         <= 1'b1;
                        err_2nd_cycle <= 1'b0;
                        ap_active     <= 1'b0;
                    end
                end else if (wait_cnt != 0) begin
                    HREADYOUT <= 1'b0;
                    HRESP     <= 1'b0;
                    wait_cnt  <= wait_cnt - 1'b1;
                end else begin
                    HREADYOUT <= 1'b1;
                    HRESP     <= 1'b0;
                    if (ap_write)
                        mem[ap_addr[8:2]] <= HWDATA;
                    ap_active <= 1'b0;
                end
            end else begin
                HREADYOUT <= 1'b1;
                HRESP     <= 1'b0;
            end

            if (sel_valid) begin
                ap_write  <= HWRITE;
                ap_addr   <= HADDR;
                ap_err    <= is_err_addr;
                ap_active <= 1'b1;
                wait_cnt  <= wait_states;
                if (is_err_addr) begin
                    HREADYOUT <= 1'b0;
                    HRESP     <= 1'b1;
                end else if (wait_states != 0) begin
                    HREADYOUT <= 1'b0;
                    HRESP     <= 1'b0;
                end else begin
                    HREADYOUT <= 1'b1;
                    HRESP     <= 1'b0;
                end
            end
        end
    end

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn)
            HRDATA <= 'b0;
        else if (sel_valid && !HWRITE && !is_err_addr)
            HRDATA <= mem[HADDR[8:2]];
    end

endmodule