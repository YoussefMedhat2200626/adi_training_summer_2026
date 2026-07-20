
class alu_driver;

    // Virtual interface to the DUT
    virtual alu_if vif;

    // Mailbox to receive transactions from generator
    mailbox #(alu_transaction) gen2drv_mbx;

    // Constructor
    function new(virtual alu_if vif, mailbox #(alu_transaction) mbx);
        this.vif = vif;
        this.gen2drv_mbx = mbx;
    endfunction

    // Run Task
    task run();
        alu_transaction txn;
        
        $display("[DRIVER] Starting driver...");
        
        forever begin
            // Get next transaction from generator
            gen2drv_mbx.get(txn);

            // Wait for falling edge to drive signals cleanly
            @(negedge vif.clk);

            // Drive signals
            vif.A      <= txn.A;
            vif.B      <= txn.B;
            vif.alu_op <= txn.alu_op;

            // Wait for processing to complete
            @(posedge vif.clk);
        end
    endtask

endclass
