import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;
class ALU_generator;
    ALU_transaction t_gen;
    int TEST_SIZE = 100000;
    mailbox#(ALU_transaction) gen_mail;
    event gen_handover;

    function new();
        this.gen_mail = new();
    endfunction

    task run_generator();
        t_gen = new();
        for (int i=0; i<TEST_SIZE; ++i) begin
           /* if (i == 0) begin
                t_gen.rst_n = 1;
                t_gen.A = 0;
                t_gen.B = 0;
                t_gen.opcode = opcode_e'(0);
                gen_mail.put(t_gen);
                @(gen_handover);
            end
            else begin
                assert(t_gen.randomize()) else $stop;
                gen_mail.put(t_gen);
                @(gen_handover);
            end*/
            assert(t_gen.randomize()) else $stop;
            gen_mail.put(t_gen);
            @(gen_handover);
        end
        test_finished  = 1;
    endtask
endclass