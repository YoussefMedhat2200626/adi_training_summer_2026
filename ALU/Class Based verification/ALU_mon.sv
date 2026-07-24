`include "ALU_tr.sv"

class alu_mon;
    virtual alu_if vif;
    mailbox #(alu_trans) mon2scb;
    
    alu_trans trans_q[$]; 

    function new(virtual alu_if vif, mailbox #(alu_trans) mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction

    task run();
        alu_trans current_trans;
        alu_trans completed_trans;

        forever begin
            @(posedge vif.clk);
            #1;
            
            if (trans_q.size() > 0) begin
                completed_trans = trans_q.pop_front(); 
                completed_trans.out      = vif.out;
                completed_trans.zero     = vif.zero;
                completed_trans.carry    = vif.carry;
                completed_trans.overflow = vif.overflow;
                
                mon2scb.put(completed_trans);
            end
            current_trans = new();
            current_trans.a      = vif.a;
            current_trans.b      = vif.b;
            current_trans.opcode = vif.opcode;
            
            trans_q.push_back(current_trans);
        end
    endtask
endclass