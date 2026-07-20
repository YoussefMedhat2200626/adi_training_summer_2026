
class alu_generator;

    // Mailbox to send transactions to the driver
    mailbox #(alu_transaction) gen2drv_mbx;
    
    // Event to signal completion
    event gen_done_ev;

    // Configuration
    int num_txns = 100;
    int scenario = 0; // 0=Random, 1=ADD/SUB, 2=AND/XOR, 4=Corner Cases

    // Constructor
    function new(mailbox #(alu_transaction) mbx, event done_ev);
        this.gen2drv_mbx = mbx;
        this.gen_done_ev = done_ev;
    endfunction

    // Run Task
    task run();
        alu_transaction txn;
        
        $display("[GENERATOR] Starting scenario %0d with %0d transactions", scenario, num_txns);

        for (int i = 0; i < num_txns; i++) begin
            txn = new();
            
            // Constrain based on scenario
            case (scenario)
                1: begin
                    if (!txn.randomize() with { alu_op == (i % 2 == 0 ? 2'b00 : 2'b01); }) 
                        $fatal(1, "Randomization failed!");
                end
                2: begin
                    if (!txn.randomize() with { alu_op == (i % 2 == 0 ? 2'b10 : 2'b11); }) 
                        $fatal(1, "Randomization failed!");
                end
                4: begin
                    // Directed corner cases
                    if (i == 0) txn.randomize() with { A == 8'hFF; B == 8'hFF; alu_op == 2'b00; }; // ADD overflow
                    else if (i == 1) txn.randomize() with { A == 8'h00; B == 8'h01; alu_op == 2'b01; }; // SUB underflow
                    else if (i == 2) txn.randomize() with { A == 8'h55; B == 8'h55; alu_op == 2'b01; }; // SUB zero
                    else if (i == 3) txn.randomize() with { A == 8'hAA; B == 8'hAA; alu_op == 2'b11; }; // XOR zero
                    else if (!txn.randomize()) $fatal(1, "Randomization failed!");
                end
                default: begin
                    // Full Random
                    if (!txn.randomize()) $fatal(1, "Randomization failed!");
                end
            endcase

            // Send to driver
            gen2drv_mbx.put(txn);
        end

        $display("[GENERATOR] Finished generating %0d transactions", num_txns);
        ->gen_done_ev; // Signal environment that generation is complete
    endtask

endclass
