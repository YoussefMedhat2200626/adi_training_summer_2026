package ahb_shared_pkg;
    localparam HBURST_WIDTH = 3;
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
    typedef enum logic [HBURST_WIDTH - 1:0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} burst_e;
    typedef enum logic [2:0] {Byte, Halfword, Word, Doubleword, four_word_line, eight_word_line} size_e;
    typedef enum logic [1:0] {IDLE,BUSY,NONSEQ,SEQ} transfer_e;
    typedef enum logic [2:0] {IDLE_S,ADDR,WAIT,ERROR,DATA_W,DATA_R} state_e;
    
endpackage