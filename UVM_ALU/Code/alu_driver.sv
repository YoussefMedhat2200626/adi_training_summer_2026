class alu_driver;
    virtual alu_interface vif;
    mailbox #(alu_transaction) gen2drv;
    event drv_done;
    event sample_ev;

    function new(virtual alu_interface vif, mailbox #(alu_transaction) gen2drv, event drv_done, event sample_ev);
        this.vif       = vif;
        this.gen2drv   = gen2drv;
        this.drv_done  = drv_done;
        this.sample_ev = sample_ev;
    endfunction

    task run();
        alu_transaction tr;
        forever begin
            gen2drv.get(tr);
            vif.A      <= tr.A;
            vif.B      <= tr.B;
            vif.opcode <= tr.opcode;
            #10;          // Wait for combinational logic propagation
            -> sample_ev; // Signal monitor to sample output
            #1;
            -> drv_done;  // Signal generator that transaction cycle is complete
        end
    endtask
endclass