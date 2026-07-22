
class generator;

    string      name       ;
    transaction t_gen        ;
    mailbox     gen_mail      ;
    event       gen_handover  ;

    function new(string name = "GENERATOR");
        this.name     = name;
        this.gen_mail = new();
    endfunction

    task send(transaction t);
        gen_mail.put(t);
        @(gen_handover);
    endtask

    task gen_reset();
        t_gen        = new();
        t_gen.rst_n  = 1'b0;
        t_gen.A      = 4'd0;
        t_gen.B      = 4'd0;
        t_gen.opcode = 2'b00;
        send(t_gen);
    endtask

    task gen_addition(int num);
        repeat(num) begin
            t_gen = new();
            assert(t_gen.randomize() with { rst_n == 1'b1; opcode == 2'b00; });
            send(t_gen);
        end
    endtask

    task gen_subtraction(int num);
        repeat(num) begin
            t_gen = new();
            assert(t_gen.randomize() with { rst_n == 1'b1; opcode == 2'b01; });
            send(t_gen);
        end
    endtask

    task gen_and(int num);
        repeat(num) begin
            t_gen = new();
            assert(t_gen.randomize() with { rst_n == 1'b1; opcode == 2'b10; });
            send(t_gen);
        end
    endtask

    task gen_xor(int num);
        repeat(num) begin
            t_gen = new();
            assert(t_gen.randomize() with { rst_n == 1'b1; opcode == 2'b11; });
            send(t_gen);
        end
    endtask

    task gen_corner();
        bit [3:0] corner[2] = '{4'b0000, 4'b1111};
        foreach(corner[i]) begin
            foreach(corner[j]) begin
                t_gen = new();
                assert(t_gen.randomize() with {
                    rst_n == 1'b1;
                    A     == corner[i];
                    B     == corner[j];
                });
                send(t_gen);
            end
        end
    endtask

    task gen_random_opcode(int num);
        repeat(num) begin
            t_gen = new();
            assert(t_gen.randomize() with { rst_n == 1'b1; });
            send(t_gen);
        end
    endtask

    task run_generator();

        int n;

        gen_reset();

        n = $urandom_range(5,10);
        gen_addition(n);

        n = $urandom_range(5,10);
        gen_subtraction(n);

        n = $urandom_range(5,10);
        gen_and(n);

        n = $urandom_range(5,10);
        gen_xor(n);

        gen_corner();

        for(int i = 0; i < 8; i++) begin
            case(i % 4)
                0: gen_addition(1);
                1: gen_subtraction(1);
                2: gen_and(1);
                3: gen_xor(1);
            endcase
        end

        gen_random_opcode(10);

    endtask

endclass
