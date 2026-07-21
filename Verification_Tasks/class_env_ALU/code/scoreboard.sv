class scoreboard;

transaction t_score;
mailbox score_mail;
int passed_test_count;
int failed_test_count;

function new();
    this.score_mail = new();
    passed_test_count = 0;
    failed_test_count = 0;
endfunction

function void display_results();
    $display("scoreboard: passed tests: %0d, failed tests: %0d", passed_test_count, failed_test_count);
endfunction

task run_scoreboard();
    bit [3:0] golden_result;

    forever begin
    t_score = new();
    score_mail.get(t_score);
    t_score.display("scoreboard");

    case(t_score.opcode)
      2'b00: golden_result = t_score.a + t_score.b;
      2'b01: golden_result = t_score.a - t_score.b;
      2'b10: golden_result = t_score.a & t_score.b;
      2'b11: golden_result = t_score.a ^ t_score.b;
      default: golden_result = 4'b0;
    endcase

    if (golden_result !== t_score.result) begin
      failed_test_count++;
      $display("scoreboard: test failed: a=%0d b=%0d opcode=%0b expected=%0d got=%0d",
             t_score.a, t_score.b, t_score.opcode, golden_result, t_score.result);
    end
    else begin
      passed_test_count++;
      $display("scoreboard: test passed: a=%0d b=%0d opcode=%0b result=%0d",
               t_score.a, t_score.b, t_score.opcode, t_score.result);
    end

    end
endtask
endclass
