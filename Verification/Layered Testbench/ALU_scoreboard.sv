import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;
class ALU_scoreboard;
    ALU_transaction t_score;
    mailbox#(ALU_transaction) score_mail;

    bit [WIDTH - 1:0] ALU_OUT_ref;
    bit carry_flag_ref, arith_flag_ref, logic_flag_ref,zero_flag_ref;

    function new();
        this.score_mail = new();
    endfunction

    function void golden_model(input ALU_transaction txn);
        if (!txn.rst_n) begin
            ALU_OUT_ref = 0;
            carry_flag_ref = 0;
            arith_flag_ref = 0;
            logic_flag_ref = 0;
            zero_flag_ref = 0;
        end
        else begin
            {carry_flag_ref,arith_flag_ref,logic_flag_ref} = 3'b000;
            case (txn.opcode)
                ADD: {carry_flag_ref,ALU_OUT_ref} = txn.A + txn.B;
                SUB: {carry_flag_ref,ALU_OUT_ref} = txn.A - txn.B;
                AND: ALU_OUT_ref = txn.A & txn.B;
                XOR: ALU_OUT_ref = txn.A ^ txn.B;
            endcase
            case (txn.opcode)
                ADD,SUB: arith_flag_ref = 1;
                AND,XOR: logic_flag_ref = 1;
            endcase
        end
        zero_flag_ref = (ALU_OUT_ref == 0);
    endfunction

    task run_scoreboard();
        forever begin
            t_score = new();
            score_mail.get(t_score);
            golden_model(t_score);

            if (ALU_OUT_ref !== t_score.ALU_OUT) begin
                $display("Error! ALU_OUT_ref = %0d, Got = %0d, at time = %0t",ALU_OUT_ref,t_score.ALU_OUT,$time);
                error_count++;
            end
            else begin
                correct_count++;
            end
            if (carry_flag_ref !== t_score.carry_flag) begin
                $display("Error! carry_flag_ref = %0d, Got = %0d, at time = %0t",carry_flag_ref,t_score.carry_flag,$time);
                error_count++;
            end
            else begin
                correct_count++;
            end
            if (arith_flag_ref !== t_score.arith_flag) begin
                $display("Error! arith_flag_ref = %0d, Got = %0d, at time = %0t",arith_flag_ref,t_score.arith_flag,$time);
                error_count++;
            end
            else begin
                correct_count++;
            end
            if (logic_flag_ref !== t_score.logic_flag) begin
                $display("Error! logic_flag_ref = %0d, Got = %0d, at time = %0t",logic_flag_ref,t_score.logic_flag,$time);
                error_count++;
            end
            else begin
                correct_count++;
            end
            if (zero_flag_ref !== t_score.zero_flag) begin
                $display("Error! zero_flag_ref = %0d, Got = %0d, at time = %0t",zero_flag_ref,t_score.zero_flag,$time);
                error_count++;
            end
            else begin
                correct_count++;
            end
        end
    endtask
endclass