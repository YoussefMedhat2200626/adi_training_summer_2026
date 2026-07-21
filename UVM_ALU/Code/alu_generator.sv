class alu_generator;
    mailbox #(alu_transaction) gen2drv;
    event drv_done;

    function new(mailbox #(alu_transaction) gen2drv, event drv_done);
        this.gen2drv  = gen2drv;
        this.drv_done = drv_done;
    endfunction

    // Sequence 1: Opcode sweep sequence
    task run_scenario_1_opcode_sweep();
        alu_transaction tr;
        for (int op = 0; op < 8; op++) begin
            tr = new();
            assert(tr.randomize() with { opcode == op; });
            gen2drv.put(tr);
            @drv_done;
        end
    endtask

    // Sequence 2: Boundary sequence
    task run_scenario_2_boundary();
        bit [7:0] bounds[6] = '{8'h00, 8'h01, 8'h7F, 8'h80, 8'hFE, 8'hFF};
        alu_transaction tr;
        foreach (bounds[i]) begin
            foreach (bounds[j]) begin
                for (int op = 0; op < 8; op++) begin
                    tr = new();
                    tr.A = bounds[i];
                    tr.B = bounds[j];
                    tr.opcode = op[2:0];
                    gen2drv.put(tr);
                    @drv_done;
                end
            end
        end
    endtask

    // Sequence 3 & 5: Carry sequence and Carryout clearing sequence
    task run_scenario_3_carry_and_clear();
        alu_transaction tr;
        repeat(30) begin
            // Trigger Carryout = 1 using ADD / SUB
            tr = new();
            assert(tr.randomize() with { opcode inside {3'b001, 3'b010}; A > 8'h80; B > 8'h80; });
            gen2drv.put(tr);
            @drv_done;

            // Immediately switch to a Non-ADD/SUB opcode to test reset to 0
            tr = new();
            assert(tr.randomize() with { opcode inside {3'b000, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111}; });
            gen2drv.put(tr);
            @drv_done;
        end
    endtask

    // Sequence 4: Zero flag targeting sequence
    task run_scenario_4_zero_flag();
        alu_transaction tr;
        for (int op = 0; op < 8; op++) begin
            tr = new();
            case (op)
                3'b000: assert(tr.randomize() with { opcode == 0; A == 8'h00; });
                3'b001: assert(tr.randomize() with { opcode == 1; (16'(A) + 16'(B)) == 256; }); // Wraparound to 0
                3'b010: assert(tr.randomize() with { opcode == 2; A == B; });                   // A - B = 0
                3'b011: assert(tr.randomize() with { opcode == 3; A == 8'hFF; });               // 255 + 1 = 0
                3'b100: assert(tr.randomize() with { opcode == 4; A == 8'h01; });               // 1 - 1 = 0
                3'b101: assert(tr.randomize() with { opcode == 5; (A & B) == 0; });
                3'b110: assert(tr.randomize() with { opcode == 6; A == 0; B == 0; });
                3'b111: assert(tr.randomize() with { opcode == 7; A == 8'hFF; });               // ~FF = 0
            endcase
            gen2drv.put(tr);
            @drv_done;
        end
    endtask

    // Sequence 6: Fully randomized sequence
    task run_scenario_5_random(int count = 1000);
        alu_transaction tr;
        repeat(count) begin
            tr = new();
            assert(tr.randomize());
            gen2drv.put(tr);
            @drv_done;
        end
    endtask
endclass