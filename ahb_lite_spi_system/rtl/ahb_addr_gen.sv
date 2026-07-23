

module ahb_addr_gen
    import ahb_lite_pkg::*;
(
    input  logic        HCLK,
    input  logic        HRESETn,
    input  logic [31:0] base_addr,     
    input  logic [2:0]  hsize,         
    input  logic [2:0]  hburst,        
    input  logic        load_en,       
    input  logic        incr_en,       
    output logic [31:0] current_addr   
);

    logic [31:0] increment;

    logic [31:0] addr_incremented;

    logic        is_wrap_r;            
    logic [31:0] wrap_mask_r;          
    logic [31:0] base_aligned_r;       

    logic [4:0]  num_beats;            
    logic [31:0] wrap_size;            
    logic [31:0] wrap_mask;            
    logic [31:0] base_aligned;         

    logic [31:0] next_addr;

    assign increment = 32'd1 << hsize;

    assign addr_incremented = current_addr + increment;

    assign num_beats     = burst_beat_count(hburst);
    assign wrap_size     = {27'd0, num_beats} << hsize;   
    assign wrap_mask     = wrap_size - 32'd1;
    assign base_aligned  = base_addr & ~wrap_mask;

    always_comb begin
        if (is_wrap_r) begin
            
            next_addr = base_aligned_r | (addr_incremented & wrap_mask_r);
        end else begin
            
            next_addr = addr_incremented;
        end
    end

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_addr  <= 32'd0;
            is_wrap_r     <= 1'b0;
            wrap_mask_r   <= 32'd0;
            base_aligned_r <= 32'd0;
        end else if (load_en) begin
            
            current_addr  <= base_addr;
            
            is_wrap_r     <= is_wrap_burst(hburst);
            wrap_mask_r   <= wrap_mask;
            base_aligned_r <= base_aligned;
        end else if (incr_en) begin
            
            current_addr  <= next_addr;
        end
        
    end

endmodule
