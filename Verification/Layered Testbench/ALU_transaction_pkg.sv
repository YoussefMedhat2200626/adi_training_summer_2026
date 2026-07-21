package ALU_transaction_pkg;
    import ALU_shared_pkg :: *;
    localparam MAXPOS = 2**(WIDTH-1) - 1, MAXNEG = -2**(WIDTH-1), ZERO = 0;
    class ALU_transaction;
        bit clk;
        rand bit rst_n;
        rand bit signed [WIDTH - 1:0] A,B;
        rand opcode_e opcode;
        bit [WIDTH - 1:0] ALU_OUT;
        bit carry_flag, arith_flag, logic_flag, zero_flag;
        bit [WIDTH - 1:0] walking_ones [WIDTH] = '{1,2,4,8,16,32,64,128};
        rand bit [WIDTH - 1:0] walking_ones_t,walking_ones_f;

        // 1.Assert reset less often
        constraint rst_n_c {
            rst_n dist {1:/97, 0:/3};
        }

        // 2.Constraint for adder inputs (A, B) to take the values (MAXPOS, ZERO and MAXNEG) 
        // more often than the other values when the opcode is addition or suntraction.
        constraint A_B_ADD_SUB {
            if (opcode == ADD || opcode == SUB) {
                A dist {MAXPOS:/90, MAXNEG:/90, ZERO:/90, [-2**(WIDTH-1) + 1:2**(WIDTH-1) - 2]:/10};
                B dist {MAXPOS:/90, MAXNEG:/90, ZERO:/90, [-2**(WIDTH-1) + 1:2**(WIDTH-1) - 2]:/10};
            }
        }
        // 3.If the opcode is AND or XOR, constraint the input A most of the time
        // to have one bit high in its 8 bits while constraining the B bits to have other random value
        constraint A_B_AND_XOR {
            walking_ones_t inside {walking_ones};
            !(walking_ones_f inside {walking_ones});
            if (opcode == AND || opcode == XOR) {
                A dist {walking_ones_t:/80,walking_ones_f:/20};
                B != A;
            }
        }

        
    endclass

endpackage