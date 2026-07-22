class scoreboard_class;
    mailbox #(transaction_class) sb_mb = new(1);
    transaction_class tr;
    int pass_cnt, fail_cnt;

    function new (mailbox #(transaction_class) env_mb);
        sb_mb = env_mb;
        pass_cnt = 0;
        fail_cnt = 0;
    endfunction

    task run_scoreboard();
        bit [4:0] expected;
        forever begin
            sb_mb.get(tr);
            case (tr.opcode)
                2'b00: expected = tr.A + tr.B;
                2'b01: expected = tr.A - tr.B;
                2'b10: expected = tr.A & tr.B;
                2'b11: expected = tr.A | tr.B;
                default: expected = 5'b00000;
            endcase
 
            if (expected === tr.ALU_Out) begin
                pass_cnt++;
                $display("[SCOREBOARD] PASS: A=%0d B=%0d opcode=%b Expected=%0d Got=%0d",
                           tr.A, tr.B, tr.opcode, expected, tr.ALU_Out);
                $display ("pss_cnt = %0d , fail_cnt = %0d", pass_cnt, fail_cnt);
            end 
            else begin
                fail_cnt++;
                $display("[SCOREBOARD] FAIL: A=%0d B=%0d opcode=%b Expected=%0d Got=%0d",
                           tr.A, tr.B, tr.opcode, expected, tr.ALU_Out);
                $display ("pss_cnt = %0d , fail_cnt = %0d", pass_cnt, fail_cnt);
            end
        end
    endtask
endclass