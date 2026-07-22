package scoreboard_pkg;
    import transaction_pkg::*;

    class scoreboard;
        mailbox sb_mbox;
        alu_item #(4) trn_sb;
        int pass_count;
        int fail_count;

        function new();
            sb_mbox = new();
        endfunction

        task run();
            static bit [3:0] golden_out;
            static bit golden_carry;

            forever begin
                trn_sb = new();
                sb_mbox.get(trn_sb);

                if(!trn_sb.RST) begin
                    golden_out = 4'h0;
                    golden_carry = 1'b0;
                end else begin
                    case (trn_sb.OpSel)
                        2'b00: {golden_carry, golden_out} = trn_sb.A + trn_sb.B;
                        2'b01: {golden_carry, golden_out} = trn_sb.A - trn_sb.B;
                        2'b10: {golden_carry, golden_out} = trn_sb.A & trn_sb.B;
                        2'b11: {golden_carry, golden_out} = trn_sb.A | trn_sb.B;
                        default: {golden_carry, golden_out} = 5'h0;
                    endcase
                end

                if (trn_sb.Out === golden_out && trn_sb.Carry === golden_carry) begin
                    pass_count++;
                end else begin
                    fail_count++;
                end
            end
        endtask

        function void report();
            $display("--------------------------------------------------");
            $display("SCOREBOARD FINAL REPORT: PASS = %0d, FAIL = %0d, TOTAL = %0d",
                       pass_count, fail_count, pass_count + fail_count);
            $display("--------------------------------------------------");
        endfunction
    endclass
endpackage : scoreboard_pkg