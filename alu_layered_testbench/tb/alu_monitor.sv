
class alu_monitor;

    // Virtual interface to the DUT
    virtual alu_if vif;

    // Mailbox to send transactions to the scoreboard
    mailbox #(alu_transaction) mon2scb_mbx;

    // Constructor
    function new(virtual alu_if vif, mailbox #(alu_transaction) mbx);
        this.vif = vif;
        this.mon2scb_mbx = mbx;
    endfunction

    // Run Task
    task run();
        alu_transaction txn;
        
        $display("[MONITOR] Starting monitor...");
        
        forever begin
            // Wait for the clock edge where data is stable
            @(posedge vif.clk);
            
            // Wait a brief moment to ensure combinational logic settles
            #1;

            // Sample the interface into a new transaction object
            txn = new();
            txn.A         = vif.A;
            txn.B         = vif.B;
            txn.alu_op    = vif.alu_op;
            txn.result    = vif.result;
            txn.carry_out = vif.carry_out;
            txn.zero      = vif.zero;

            // Send to scoreboard
            mon2scb_mbx.put(txn);
        end
    endtask

endclass
