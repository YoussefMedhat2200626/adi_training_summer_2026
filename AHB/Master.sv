module ahb_master_fsm (
    input  logic        hclk,
    input  logic        hresetn,

    // Microcontroller Request Interface 
    input  logic        i_req_valid,
    input  logic        i_req_write,
    input  logic [31:0] i_req_addr,
    input  logic [31:0] i_req_wdata,
    input  logic [2:0]  i_req_size,
    input  logic [2:0]  i_req_burst,
    input  logic        i_req_busy,
    input  logic [3:0]  i_req_prot,
    input  logic        i_req_lock,

    // Microcontroller Feedback & Response Interface
    output logic        o_req_ready,
    output logic        o_resp_valid,
    output logic [31:0] o_resp_rdata,
    output logic        o_resp_error,

    // AHB Master Interface
    output logic [31:0] haddr,
    output logic [1:0]  htrans,
    output logic        hwrite,
    output logic [2:0]  hsize,
    output logic [2:0]  hburst,
    output logic [3:0]  hprot,    
    output logic        hmastlock,
    output logic [31:0] hwdata,
    
    input  logic [31:0] hrdata,
    input  logic        hready,
    input  logic        hresp             
);

    // AHB HTRANS Encoding
    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_BUSY   = 2'b01;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;
    localparam logic [1:0] HTRANS_SEQ    = 2'b11;

    localparam logic HRESP_OKAY  = 1'b0;
    localparam logic HRESP_ERROR = 1'b1;

    // FSM States
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        ADDR_PHASE  = 2'b01,
        DATA_PHASE  = 2'b10,
        BUSY_WAIT   = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Internal Registers for Transaction & Burst Tracking
    logic [31:0] addr_reg;
    logic [31:0] wdata_reg;
    logic        write_reg;
    logic [2:0]  size_reg;
    logic [2:0]  burst_reg;
    logic [3:0]  beats_left;
    logic [3:0]  prot_reg;
    logic        lock_reg;
    
    // Decode HBURST into total beats
    function automatic logic [3:0] get_total_beats(logic [2:0] burst_type);
        case (burst_type)
            3'b000: return 4'd1;  // SINGLE
            3'b010, 3'b011: return 4'd4;  // WRAP4, INCR4
            3'b100, 3'b101: return 4'd8;  // WRAP8, INCR8
            3'b110, 3'b111: return 4'd16; // WRAP16, INCR16
            default: return 4'd1; // INCR (undefined length) defaults to 1 beat
        endcase
    endfunction

    // Calculate next address based on HSIZE
    function automatic logic [31:0] get_next_addr(logic [31:0] current_addr, logic [2:0] size);
        case (size)
            3'b000: return current_addr + 32'd1; // 8-bit (Byte)
            3'b001: return current_addr + 32'd2; // 16-bit (Halfword)
            3'b010: return current_addr + 32'd4; // 32-bit (Word)
            default: return current_addr + 32'd4;
        endcase
    endfunction

    // State Register & Burst Tracking
    always_ff @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            current_state <= IDLE;
            addr_reg      <= 0;
            wdata_reg     <= 0;
            write_reg     <= 1'b0;
            size_reg      <= 3'b010; // Default to 32-bit
            burst_reg     <= 3'b000;
            beats_left    <= 0;
            prot_reg      <= 4'b0011; // Default to Non-cacheable, Non-bufferable, Privileged, Data access
            lock_reg      <= 1'b0;
        end else begin
            current_state <= next_state;

            case (current_state)
                IDLE: begin
                    if (i_req_valid) begin
                        addr_reg   <= i_req_addr;
                        write_reg  <= i_req_write;
                        size_reg   <= i_req_size;
                        burst_reg  <= i_req_burst;
                        beats_left <= get_total_beats(i_req_burst);
                        prot_reg   <= i_req_prot;
                        lock_reg   <= i_req_lock; 
                    end
                end

                ADDR_PHASE: begin
                    wdata_reg <= i_req_wdata; 
                end

                DATA_PHASE: begin
                    if (hready && hresp == HRESP_OKAY) begin
                        if (beats_left > 1) begin
                            // Auto-increment address for next beat
                            addr_reg   <= get_next_addr(addr_reg, size_reg);
                            beats_left <= beats_left - 1;
                            wdata_reg  <= i_req_wdata; // Grab next write data from Microcontroller
                        end else if (i_req_valid) begin
                            // Overlapping DATA_PHASE with new ADDR_PHASE request
                            addr_reg   <= i_req_addr;
                            write_reg  <= i_req_write;
                            size_reg   <= i_req_size;
                            burst_reg  <= i_req_burst;
                            beats_left <= get_total_beats(i_req_burst);
                            prot_reg   <= i_req_prot; 
                            lock_reg   <= i_req_lock; 
                        end
                    end
                end
                
                // Keep registers stable during BUSY_WAIT   
                default: ;
            endcase
        end
    end

    // Next State and Outputs
    always_comb begin
        // Default AHB Outputs
        next_state = current_state;
        htrans     = HTRANS_IDLE;
        haddr      = addr_reg;
        hwrite     = write_reg;
        hsize      = size_reg;
        hburst     = burst_reg;
        hwdata     = wdata_reg;
        hprot      = prot_reg;
        hmastlock  = lock_reg;

        // Default Microcontroller Feedback
        o_req_ready  = 1'b0;
        o_resp_valid = 1'b0;
        o_resp_error = 1'b0;
        o_resp_rdata = hrdata;

        case (current_state)

            IDLE: begin
                o_req_ready = 1'b1;
                if (i_req_valid) begin
                    next_state = ADDR_PHASE;
                end
            end

            ADDR_PHASE: begin
                haddr  = addr_reg;
                htrans = HTRANS_NONSEQ; // First beat is always NONSEQ
                
                next_state = DATA_PHASE; // ADDR_PHASE always takes one clk cycle
            end

            DATA_PHASE: begin
                // If bursting, pipeline the NEXT address and set SEQ
                if (beats_left > 1) begin
                    haddr  = get_next_addr(addr_reg, size_reg);
                    htrans = i_req_busy ? HTRANS_BUSY : HTRANS_SEQ;
                end else begin
                    // Last beat
                    if (i_req_valid) begin
                        haddr = i_req_addr;
                        htrans = HTRANS_NONSEQ;
                    end else begin
                        htrans = HTRANS_IDLE;
                    end
                end

                if (hready == 1'b0) begin
                    // Wait state
                    next_state = DATA_PHASE; 
                end
                else if (hready == 1'b1 && hresp == HRESP_OKAY) begin
                    o_resp_valid = 1'b1;
                    
                    if (beats_left > 1) begin
                        next_state = i_req_busy ? BUSY_WAIT : DATA_PHASE;
                    end else begin
                        o_req_ready = 1'b1;
                        next_state  = i_req_valid ? ADDR_PHASE : IDLE;
                    end
                end 
                else if (hready == 1'b1 && hresp == HRESP_ERROR) begin
                    // Transfer failed
                    o_resp_error = 1'b1;
                    o_req_ready  = 1'b1;
                    next_state   = IDLE;
                end
            end

            BUSY_WAIT: begin
                htrans = HTRANS_BUSY;
                haddr  = get_next_addr(addr_reg, size_reg);
                
                if (!i_req_busy) begin
                    next_state = DATA_PHASE; // Resume burst data processing
                end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule