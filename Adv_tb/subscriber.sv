class subscriber;

    string      name       ;
    transaction t_sub        ;
    mailbox     subs_mail     ;

    covergroup cg;
        option.per_instance = 1;

        cp_opcode : coverpoint t_sub.opcode {
            bins add_op = {2'b00};
            bins sub_op = {2'b01};
            bins and_op = {2'b10};
            bins xor_op = {2'b11};
        }

        cp_A : coverpoint t_sub.A {
            bins zero   = {4'b0000};
            bins ones   = {4'b1111};
            bins others = {[4'b0001:4'b1110]};
        }

        cp_B : coverpoint t_sub.B {
            bins zero   = {4'b0000};
            bins ones   = {4'b1111};
            bins others = {[4'b0001:4'b1110]};
        }

        cp_result : coverpoint t_sub.result {
            bins all_values[16] = {[0:15]};
        }

        cp_carry : coverpoint t_sub.carry {
            bins asserted   = {1'b1};
            bins deasserted = {1'b0};
        }

        cross_op_corners : cross cp_opcode, cp_A, cp_B;

    endgroup

    function new(string name = "SUBSCRIBER");
        this.name      = name;
        this.subs_mail = new();
        cg             = new();
    endfunction

    task run_subscriber();
        forever begin
            subs_mail.get(t_sub);
            cg.sample();
        end
    endtask

    function void display_coverage_percentage();
        $display("=====================================================");
        $display(" Functional Coverage = %0.2f %%", cg.get_coverage());
        $display("=====================================================");
    endfunction

endclass
