interface alu_if #(parameter WIDTH = 8) (input logic clk);

    logic             rst;
    logic [WIDTH-1:0] a, b;
    logic [1:0]       alu_fun;
    logic             alu_enable;
    logic [WIDTH-1:0] alu_out;
    logic             alu_valid;

    // Driver clocking block
    clocking drv_cb @(posedge clk);
        default input #1step output #1step;
        output rst, a, b, alu_fun, alu_enable;
        input  alu_out, alu_valid;
    endclocking

    // Monitor clocking block
    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst, a, b, alu_fun, alu_enable, alu_out, alu_valid;
    endclocking

    modport DRV (clocking drv_cb, input clk);
    modport MON (clocking mon_cb, input clk);

endinterface
