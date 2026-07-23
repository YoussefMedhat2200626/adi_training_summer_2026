

module ahb_master_fsm
    import ahb_lite_pkg::*;
(
        input  logic        HCLK,
    input  logic        HRESETn,

        input  logic        HREADY,         
    input  logic        HRESP,          

        input  logic        cmd_valid,      
    input  logic        cmd_last,       
    output logic        cmd_ready,      

        output logic        rsp_valid,      
    output logic        rsp_error,      

        output logic [1:0]  htrans_out,     
    output logic        addr_load_en,   
    output logic        addr_incr_en,   
    output logic        burst_load_en,  
    output logic        burst_count_en, 
    output logic        ctrl_latch_en,  
    output logic        wdata_latch_en, 

        input  logic        burst_last,     
    input  logic        burst_active,   
    input  logic [2:0]  hburst_reg      
);

    mst_state_t state, next_state;

    mst_state_t resume_state, next_resume_state;

    logic is_single_or_last;
    logic is_incr_undef;

    assign is_incr_undef = (hburst_reg == HBURST_INCR);

    logic data_phase_active;
    logic data_phase_error;

    assign is_single_or_last = burst_last ||
                               (is_incr_undef && cmd_last) ||
                               (hburst_reg == HBURST_SINGLE);

    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state             <= MST_IDLE;
            resume_state      <= MST_IDLE;
            data_phase_active <= 1'b0;
        end else begin
            state             <= next_state;
            resume_state      <= next_resume_state;
            
            if (HREADY) begin
                data_phase_active <= (htrans_out == HTRANS_NONSEQ || htrans_out == HTRANS_SEQ);
            end
        end
    end

    always_comb begin
        
        next_state        = state;
        next_resume_state = resume_state;

        case (state)

            MST_IDLE: begin
                if (cmd_valid && HREADY)
                    next_state = MST_NONSEQ;
            end

            MST_NONSEQ: begin
                if (HRESP) begin
                    
                    next_state = MST_ERROR_RSP;
                end else if (!HREADY) begin
                    
                    next_state        = MST_WAIT_RESP;
                    next_resume_state = MST_NONSEQ;
                end else begin

                    if (!is_single_or_last) begin
                        
                        next_state = MST_SEQ;
                    end else if (cmd_valid) begin
                        
                        next_state = MST_NONSEQ;
                    end else begin
                        
                        next_state = MST_IDLE;
                    end
                end
            end

            MST_SEQ: begin
                if (HRESP) begin
                    
                    next_state = MST_ERROR_RSP;
                end else if (!HREADY) begin
                    
                    next_state        = MST_WAIT_RESP;
                    next_resume_state = MST_SEQ;
                end else begin
                    
                    if (!is_single_or_last) begin
                        
                        next_state = MST_SEQ;
                    end else if (cmd_valid) begin
                        
                        next_state = MST_NONSEQ;
                    end else begin
                        
                        next_state = MST_IDLE;
                    end
                end
            end

            MST_WAIT_RESP: begin
                if (HRESP) begin
                    
                    next_state = MST_ERROR_RSP;
                end else if (HREADY) begin

                    if (resume_state == MST_NONSEQ || resume_state == MST_SEQ) begin
                        if (!is_single_or_last) begin
                            next_state = MST_SEQ;
                        end else if (cmd_valid) begin
                            next_state = MST_NONSEQ;
                        end else begin
                            next_state = MST_IDLE;
                        end
                    end else begin
                        next_state = MST_IDLE;
                    end
                end
                
            end

            MST_ERROR_RSP: begin
                if (HREADY) begin
                    
                    next_state = MST_IDLE;
                end
                
            end

            default: next_state = MST_IDLE;
        endcase
    end

    always_comb begin
        case (state)
            MST_IDLE: begin
                htrans_out = HTRANS_IDLE;
            end

            MST_NONSEQ:
                htrans_out = HTRANS_NONSEQ;

            MST_SEQ:
                htrans_out = HTRANS_SEQ;

            MST_WAIT_RESP: begin
                
                if (resume_state == MST_SEQ)
                    htrans_out = HTRANS_SEQ;
                else
                    htrans_out = HTRANS_NONSEQ;
            end

            MST_ERROR_RSP:
                
                htrans_out = HTRANS_IDLE;

            default:
                htrans_out = HTRANS_IDLE;
        endcase
    end

    always_comb begin
        
        addr_load_en   = 1'b0;
        addr_incr_en   = 1'b0;
        burst_load_en  = 1'b0;
        burst_count_en = 1'b0;
        ctrl_latch_en  = 1'b0;
        wdata_latch_en = 1'b0;
        cmd_ready      = 1'b0;

        rsp_valid = data_phase_active && HREADY && !HRESP;
        rsp_error = data_phase_active && HREADY && HRESP;

        case (state)
            MST_IDLE: begin
                
                cmd_ready = 1'b1;

                if (cmd_valid && HREADY) begin
                    
                    addr_load_en   = 1'b1;  
                    burst_load_en  = 1'b1;  
                    ctrl_latch_en  = 1'b1;  
                    wdata_latch_en = 1'b1;  
                end
            end

            MST_NONSEQ: begin
                if (HREADY && !HRESP) begin
                    
                    burst_count_en = 1'b1;  

                    if (!is_single_or_last) begin
                        
                        addr_incr_en   = 1'b1;
                        wdata_latch_en = 1'b1;  
                    end else if (cmd_valid) begin
                        
                        cmd_ready      = 1'b1;
                        addr_load_en   = 1'b1;
                        burst_load_en  = 1'b1;
                        ctrl_latch_en  = 1'b1;
                        wdata_latch_en = 1'b1;
                    end else begin
                        cmd_ready = 1'b1;  
                    end
                end
            end

            MST_SEQ: begin
                if (HREADY && !HRESP) begin
                    
                    burst_count_en = 1'b1;

                    if (!is_single_or_last) begin
                        
                        addr_incr_en   = 1'b1;
                        wdata_latch_en = 1'b1;
                    end else if (cmd_valid) begin
                        
                        cmd_ready      = 1'b1;
                        addr_load_en   = 1'b1;
                        burst_load_en  = 1'b1;
                        ctrl_latch_en  = 1'b1;
                        wdata_latch_en = 1'b1;
                    end else begin
                        cmd_ready = 1'b1;
                    end
                end
            end

            MST_WAIT_RESP: begin

                if (HREADY && !HRESP) begin
                    burst_count_en = 1'b1;

                    if (!is_single_or_last) begin
                        addr_incr_en   = 1'b1;
                        wdata_latch_en = 1'b1;
                    end else if (cmd_valid) begin
                        cmd_ready      = 1'b1;
                        addr_load_en   = 1'b1;
                        burst_load_en  = 1'b1;
                        ctrl_latch_en  = 1'b1;
                        wdata_latch_en = 1'b1;
                    end else begin
                        cmd_ready = 1'b1;
                    end
                end
            end

            MST_ERROR_RSP: begin
                if (HREADY) begin
                    
                    cmd_ready = 1'b1;  
                end
            end

            default: begin
                cmd_ready = 1'b1;
            end
        endcase
    end

endmodule
