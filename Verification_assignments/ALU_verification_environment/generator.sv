package alu_generator_pkg;
  import transaction_pkg::*;
  
  class generator;
      mailbox gen_mbox;
      event gen_event;
      alu_item #(4) trn_gen;
      int i;

    function new();
        gen_mbox = new();
    endfunction

    task run();
        int i;
        trn_gen = new();

        for (i = 0; i < 100; i++) begin

            case (i % 4)
                0: begin
                    assert(trn_gen.randomize() with {OpSel == 2'b00;});
                end
                1: begin
                    assert(trn_gen.randomize() with {OpSel == 2'b01;});
                end
                2: begin
                    assert(trn_gen.randomize() with {OpSel == 2'b10;});
                end
                default: begin
                    assert(trn_gen.randomize() with {OpSel == 2'b11;});
                end
            endcase

            gen_mbox.put(trn_gen);
            @(gen_event);
        end

        send_directed_case(1'b1, 4'h0, 4'h0, 2'b00);
        send_directed_case(1'b1, 4'hF, 4'h0, 2'b01);
        send_directed_case(1'b1, 4'h0, 4'hF, 2'b10);
        send_directed_case(1'b1, 4'hF, 4'hF, 2'b11);
        send_directed_case(1'b1, 4'hA, 4'h5, 2'b00);
    endtask

    task send_directed_case(input bit rst, input bit [3:0] a, input bit [3:0] b, input bit [1:0] op);
        trn_gen.RST = rst;
        trn_gen.A = a;
        trn_gen.B = b;
        trn_gen.OpSel = op;
        gen_mbox.put(trn_gen);
        @(gen_event);
    endtask

endclass : generator

endpackage : alu_generator_pkg