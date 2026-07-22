// alu_agent.sv, generator + driver + monitor
class alu_agent;

    alu_generator generator;
    alu_driver    driver;
    alu_monitor   monitor;

    mailbox #(alu_transaction) gen2drv;  // internal: generator -> driver
    mailbox #(alu_transaction) mon2sb;  // exposed: monitor -> scoreboard

    function new(virtual alu_if vif, mailbox #(alu_transaction) mon2sb,
                 int num_transactions, int num_samples);
        this.mon2sb = mon2sb;
        gen2drv       = new();

        generator = new(gen2drv, num_transactions);
        driver    = new(vif, gen2drv, num_transactions);
        monitor   = new(vif, mon2sb, num_samples);
    endfunction

    task run();
        fork
            generator.run();
            driver.run();
            monitor.run();
        join
    endtask

endclass
