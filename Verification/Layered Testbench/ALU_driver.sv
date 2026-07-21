import ALU_shared_pkg::*;
import ALU_transaction_pkg :: *;

class ALU_driver;
    ALU_transaction t_driver;
    mailbox#(ALU_transaction) driver_mail;
    event driver_handover;
    virtual ALU_if driver_if;
    bit first_txn = 1;

    function new();
        this.driver_mail = new();
    endfunction

    task run_driver();
        forever begin
            t_driver = new();
            driver_mail.get(t_driver);
            if (!first_txn) @(negedge driver_if.clk);
            first_txn = 0;

            driver_if.rst_n = t_driver.rst_n;
            driver_if.A = t_driver.A;
            driver_if.B = t_driver.B;
            driver_if.opcode = t_driver.opcode;
            -> driver_handover;
        end


    endtask
endclass