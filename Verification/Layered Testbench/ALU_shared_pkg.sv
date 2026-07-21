package ALU_shared_pkg;
    typedef enum bit [1:0] {ADD,SUB,AND,XOR} opcode_e;
    localparam WIDTH = 8;
    int error_count = 0, correct_count = 0;
    bit test_finished;

endpackage