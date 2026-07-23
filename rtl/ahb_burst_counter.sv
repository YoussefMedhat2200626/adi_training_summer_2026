

module ahb_burst_counter
    import ahb_lite_pkg::*;
(
    input  logic       HCLK,
    input  logic       HRESETn,
    input  logic [2:0] hburst,          
    input  logic       load_en,         
    input  logic       count_en,        
    output logic       burst_last,      
    output logic       burst_active,    
    output logic [4:0] beats_remaining  
);

        logic [4:0] beat_count_r;   
    logic       active_r;       
    logic       is_incr_burst;  

        assign is_incr_burst = (hburst == HBURST_INCR);

        always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            beat_count_r <= 5'd0;
            active_r     <= 1'b0;
        end else if (load_en) begin

            beat_count_r <= burst_beat_count(hburst);
            active_r     <= 1'b1;
        end else if (count_en && active_r) begin
            if (beat_count_r > 5'd1) begin
                
                beat_count_r <= beat_count_r - 5'd1;
            end else if (beat_count_r == 5'd1) begin
                
                beat_count_r <= 5'd0;
                active_r     <= 1'b0;
            end

        end
    end

    assign burst_last = active_r && count_en && (beat_count_r == 5'd1);

    assign burst_active = active_r;

    assign beats_remaining = beat_count_r;

endmodule
