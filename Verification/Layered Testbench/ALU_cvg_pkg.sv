package ALU_cvg_pkg;
import ALU_shared_pkg::*;
import ALU_transaction_pkg::*;

    class ALU_coverage;
        ALU_transaction ALU_cvg_txn;
        mailbox#(ALU_transaction) cvg_mail;

        covergroup CovCode;
            A_cp: coverpoint ALU_cvg_txn.A {
                bins A_data_0 = {ZERO};
                bins A_data_max = {MAXPOS};
                bins A_data_min = {MAXNEG};
                bins A_data_default = default;
            }
            B_cp: coverpoint ALU_cvg_txn.B {
                bins B_data_0 = {ZERO};
                bins B_data_max = {MAXPOS};
                bins B_data_min = {MAXNEG};
                bins B_data_default = default;
            }
            A_logical_cp: coverpoint ALU_cvg_txn.A iff (ALU_cvg_txn.opcode == AND || ALU_cvg_txn.opcode == XOR) {
                bins A_walking_ones [] = {1,2,4,8,16,32,64,-128};
            }
            opcode_cp: coverpoint ALU_cvg_txn.opcode {
                bins arith_bins [] = {ADD,SUB};
                bins logic_bins [] = {AND,XOR};
                bins trans = (ADD => SUB => AND => XOR);
            }
            opcode_A_cross: cross opcode_cp, A_cp {
                illegal_bins i_bin1 = binsof(opcode_cp.trans)  && binsof(A_cp.A_data_max);
                illegal_bins i_bin2 = binsof(opcode_cp.trans) && binsof(A_cp.A_data_0);
            }
            opcode_B_cross: cross opcode_cp, B_cp {
                illegal_bins i_bin1 = binsof(opcode_cp.trans) && binsof(B_cp.B_data_min);
            }
        endgroup

        function new();
            CovCode = new();
            cvg_mail = new();
        endfunction

        task run_coverage();
            forever begin
                ALU_cvg_txn = new();
                cvg_mail.get(ALU_cvg_txn);
                CovCode.sample();
            end
        endtask
        
        
    endclass

endpackage