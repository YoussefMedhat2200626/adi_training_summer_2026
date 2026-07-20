package ahb_pkg;

    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        BUSY   = 2'b01,
        NONSEQ = 2'b10,
        SEQ    = 2'b11    
    } trans_type;

    typedef enum logic [2:0] {
        BYTE     = 3'b000,
        HALFWORD = 3'b001,
        WORD     = 3'b010    
    } data_type;

    typedef enum logic [2:0]
    { OKAY

    }error_type;

    typedef enum logic [2:0] {
        SINGLE  = 3'b000,
        INCR    = 3'b001,
        INCR4   = 3'b011,
        INCR8   = 3'b101,
        INCR16  = 3'b111
    } burst_type;

    typedef enum logic[1:0] {
        IDLE_SYS,
        ADDR,
        WRITE,
        READ         
    } master_state;

endpackage : ahb_pkg