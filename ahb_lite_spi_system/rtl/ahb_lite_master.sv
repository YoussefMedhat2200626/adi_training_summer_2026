

module ahb_lite_master
    import ahb_lite_pkg::*;
(
        input  logic        HCLK,
    input  logic        HRESETn,

        output logic [31:0] HADDR,          
    output logic [31:0] HWDATA,         
    output logic [1:0]  HTRANS,         
    output logic        HWRITE,         
    output logic [2:0]  HSIZE,          
    output logic [2:0]  HBURST,         
    output logic [3:0]  HPROT,          
    output logic        HMASTLOCK,      

        input  logic [31:0] HRDATA,         
    input  logic        HREADY,         
    input  logic        HRESP,          

        input  logic        cmd_valid,      
    output logic        cmd_ready,      
    input  logic [31:0] cmd_addr,       
    input  logic [31:0] cmd_wdata,      
    input  logic        cmd_write,      
    input  logic [2:0]  cmd_burst,      
    input  logic [2:0]  cmd_size,       
    input  logic        cmd_last,       

        output logic        rsp_valid,      
    output logic [31:0] rsp_rdata,      
    output logic        rsp_error       
);

    assign HPROT     = HPROT_DEFAULT;   
    assign HMASTLOCK = 1'b0;            

    logic        addr_load_en;
    logic        addr_incr_en;
    logic        burst_load_en;
    logic        burst_count_en;
    logic        ctrl_latch_en;
    logic        wdata_latch_en;
    logic        burst_last;
    logic        burst_active;
    logic [1:0]  htrans_fsm;
    logic        fsm_rsp_valid;
    logic        fsm_rsp_error;
    logic        fsm_cmd_ready;

    logic        hwrite_r;
    logic [2:0]  hsize_r;
    logic [2:0]  hburst_r;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            hwrite_r <= 1'b0;
            hsize_r  <= HSIZE_WORD;
            hburst_r <= HBURST_SINGLE;
        end else if (ctrl_latch_en) begin
            hwrite_r <= cmd_write;
            hsize_r  <= cmd_size;
            hburst_r <= cmd_burst;
        end
    end

    logic [31:0] wdata_hold_r;
    logic [31:0] hwdata_r;

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            wdata_hold_r <= 32'h0;
        end else if (wdata_latch_en) begin
            wdata_hold_r <= cmd_wdata;
        end
    end

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            hwdata_r <= 32'h0;
        end else if (HREADY && (htrans_fsm == HTRANS_NONSEQ || htrans_fsm == HTRANS_SEQ)) begin
            hwdata_r <= wdata_hold_r;
        end
    end

    logic [31:0] current_addr;

    ahb_addr_gen u_addr_gen (
        .HCLK         (HCLK),
        .HRESETn      (HRESETn),
        .base_addr    (cmd_addr),
        .hsize        (cmd_size),
        .hburst       (cmd_burst),
        .load_en      (addr_load_en),
        .incr_en      (addr_incr_en),
        .current_addr (current_addr)
    );

    logic [4:0] beats_remaining;

    ahb_burst_counter u_burst_cnt (
        .HCLK            (HCLK),
        .HRESETn         (HRESETn),
        .hburst          (cmd_burst),
        .load_en         (burst_load_en),
        .count_en        (burst_count_en),
        .burst_last      (burst_last),
        .burst_active    (burst_active),
        .beats_remaining (beats_remaining)
    );

    ahb_master_fsm u_fsm (
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .HREADY         (HREADY),
        .HRESP          (HRESP),
        .cmd_valid      (cmd_valid),
        .cmd_last       (cmd_last),
        .cmd_ready      (fsm_cmd_ready),
        .rsp_valid      (fsm_rsp_valid),
        .rsp_error      (fsm_rsp_error),
        .htrans_out     (htrans_fsm),
        .addr_load_en   (addr_load_en),
        .addr_incr_en   (addr_incr_en),
        .burst_load_en  (burst_load_en),
        .burst_count_en (burst_count_en),
        .ctrl_latch_en  (ctrl_latch_en),
        .wdata_latch_en (wdata_latch_en),
        .burst_last     (burst_last),
        .burst_active   (burst_active),
        .hburst_reg     (hburst_r)
    );

    assign HTRANS = htrans_fsm;
    assign HADDR  = current_addr;
    assign HWDATA = hwdata_r;
    assign HWRITE = hwrite_r;
    assign HSIZE  = hsize_r;
    assign HBURST = hburst_r;

    assign cmd_ready = fsm_cmd_ready;
    assign rsp_valid = fsm_rsp_valid;
    assign rsp_rdata = HRDATA;           
    assign rsp_error = fsm_rsp_error;

endmodule
