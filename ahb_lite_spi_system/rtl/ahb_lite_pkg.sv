

package ahb_lite_pkg;

    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter NUM_SLAVES = 3;

    typedef enum logic [1:0] {
        HTRANS_IDLE   = 2'b00,   
        HTRANS_BUSY   = 2'b01,   
        HTRANS_NONSEQ = 2'b10,   
        HTRANS_SEQ    = 2'b11    
    } htrans_t;

    typedef enum logic [2:0] {
        HBURST_SINGLE = 3'b000,  
        HBURST_INCR   = 3'b001,  
        HBURST_WRAP4  = 3'b010,  
        HBURST_INCR4  = 3'b011,  
        HBURST_WRAP8  = 3'b100,  
        HBURST_INCR8  = 3'b101,  
        HBURST_WRAP16 = 3'b110,  
        HBURST_INCR16 = 3'b111   
    } hburst_t;

    typedef enum logic [2:0] {
        HSIZE_BYTE  = 3'b000,    
        HSIZE_HALF  = 3'b001,    
        HSIZE_WORD  = 3'b010     
    } hsize_t;

    typedef enum logic {
        HRESP_OKAY  = 1'b0,
        HRESP_ERROR = 1'b1
    } hresp_t;

    typedef enum logic [2:0] {
        MST_IDLE      = 3'b000,  
        MST_NONSEQ    = 3'b001,  
        MST_SEQ       = 3'b010,  
        MST_WAIT_RESP = 3'b011,  
        MST_ERROR_RSP = 3'b100   
    } mst_state_t;

    parameter logic [3:0] HPROT_DEFAULT = 4'b0011;  

    parameter SLAVE_ADDR_WIDTH = 10;  

    function automatic logic [4:0] burst_beat_count(input logic [2:0] hburst);
        case (hburst)
            HBURST_SINGLE: return 5'd1;
            HBURST_INCR:   return 5'd0;   
            HBURST_WRAP4,
            HBURST_INCR4:  return 5'd4;
            HBURST_WRAP8,
            HBURST_INCR8:  return 5'd8;
            HBURST_WRAP16,
            HBURST_INCR16: return 5'd16;
            default:       return 5'd1;
        endcase
    endfunction

    function automatic logic is_wrap_burst(input logic [2:0] hburst);
        case (hburst)
            HBURST_WRAP4,
            HBURST_WRAP8,
            HBURST_WRAP16: return 1'b1;
            default:       return 1'b0;
        endcase
    endfunction

endpackage
