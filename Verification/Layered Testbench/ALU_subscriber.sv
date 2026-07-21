import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;

class ALU_subscriber;
    mailbox#(ALU_transaction) sub_mail;

    // Analysis ports for coverage and scoreboard
    mailbox#(ALU_transaction) scoreboard_mail;
    mailbox#(ALU_transaction) coverage_mail;

    function new();
        this.sub_mail = new();
        this.scoreboard_mail = new();
        this.coverage_mail = new();
    endfunction

    task run_subscriber();
        forever begin
            ALU_transaction t_sub = new();
            sub_mail.get(t_sub);

            // Fork to send to both scoreboard and coverage in parallel
            fork
                send_to_scoreboard(t_sub);
                send_to_coverage(t_sub);
            join_none
        end
    endtask

    task send_to_scoreboard(ALU_transaction txn);
        ALU_transaction t_score = new();
        // Deep copy transaction
        t_score.rst_n = txn.rst_n;
        t_score.A = txn.A;
        t_score.B = txn.B;
        t_score.opcode = txn.opcode;
        t_score.ALU_OUT = txn.ALU_OUT;
        t_score.carry_flag = txn.carry_flag;
        t_score.arith_flag = txn.arith_flag;
        t_score.logic_flag = txn.logic_flag;
        t_score.zero_flag = txn.zero_flag;
        scoreboard_mail.put(t_score);
    endtask

    task send_to_coverage(ALU_transaction txn);
        ALU_transaction t_cvg = new();
        // Deep copy transaction for coverage
        t_cvg.rst_n = txn.rst_n;
        t_cvg.A = txn.A;
        t_cvg.B = txn.B;
        t_cvg.opcode = txn.opcode;
        t_cvg.ALU_OUT = txn.ALU_OUT;
        t_cvg.carry_flag = txn.carry_flag;
        t_cvg.arith_flag = txn.arith_flag;
        t_cvg.logic_flag = txn.logic_flag;
        t_cvg.zero_flag = txn.zero_flag;
        coverage_mail.put(t_cvg);
    endtask
endclass
