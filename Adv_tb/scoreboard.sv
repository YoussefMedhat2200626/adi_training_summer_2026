class scoreboard;

    string      name        ;
    transaction t_score       ;
    mailbox     scor_mail      ;

    int passed_test_cases ;
    int failed_test_cases ;

    function new(string name = "SCOREBOARD");
        this.name      = name;
        this.scor_mail = new();
    endfunction

    task run_scoreboard();

        bit [4:0] golden_sum   ;
        bit [3:0] golden_res   ;
        bit       golden_carry ;

        forever begin

            t_score = new();
            scor_mail.get(t_score);
            t_score.display_transaction("SCOREBOARD");
            $display("Scoreboard has received the data from the monitor at time : %0t", $realtime());

            if(t_score.rst_n == 1'b0) begin

                if(t_score.result == 4'd0 && t_score.carry == 1'b0) begin
                    $display("Reset Test Case Passed at time : %0t", $realtime());
                    passed_test_cases++;
                end
                else begin
                    $display("Reset Test Case FAILED at time : %0t (result=%0d carry=%0d)",
                              $realtime(), t_score.result, t_score.carry);
                    failed_test_cases++;
                end

            end

            else begin

                case(t_score.opcode)

                    2'b00: begin
                        golden_sum   = {1'b0, t_score.A} + {1'b0, t_score.B};
                        golden_res   = golden_sum[3:0];
                        golden_carry = golden_sum[4];
                    end

                    2'b01: begin
                        golden_res   = t_score.A - t_score.B;
                        golden_carry = (t_score.A < t_score.B);
                    end

                    2'b10: begin
                        golden_res   = t_score.A & t_score.B;
                        golden_carry = 1'b0;
                    end

                    2'b11: begin
                        golden_res   = t_score.A ^ t_score.B;
                        golden_carry = 1'b0;
                    end

                    default: begin
                        golden_res   = 'x;
                        golden_carry = 'x;
                    end

                endcase

                if(t_score.result == golden_res && t_score.carry == golden_carry) begin
                    $display("Test Case Passed [opcode=%0b] Expected result=%0d carry=%0d at time : %0t",
                              t_score.opcode, golden_res, golden_carry, $realtime());
                    passed_test_cases++;
                end
                else begin
                    $display("Test Case FAILED [opcode=%0b] A=%0d B=%0d Expected result=%0d carry=%0d | Got result=%0d carry=%0d at time : %0t",
                              t_score.opcode, t_score.A, t_score.B, golden_res, golden_carry, t_score.result, t_score.carry, $realtime());
                    failed_test_cases++;
                end

            end

        end

    endtask

    function void display_test_cases_report();
        $display("=====================================================");
        $display(" Passed Test Cases : %0d", passed_test_cases);
        $display(" Failed Test Cases : %0d", failed_test_cases);
        $display("=====================================================");
    endfunction

endclass