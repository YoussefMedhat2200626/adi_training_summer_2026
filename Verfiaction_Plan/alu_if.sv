`timescale 1ns/1ps

interface alu_if #(parameter WIDTH = 4) (input bit CLK);

    logic [WIDTH-1:0] A;
    logic [WIDTH-1:0] B;
    logic [1:0]       OP;
    logic              RST;

    logic              Zero_Flag;
    logic              Arithm_FLag;
    logic              Logic_Flag;
    logic              Carry_Flag;
    logic [WIDTH-1:0] Result;

    clocking drv_cb @(posedge CLK);
        default input #1step output #2;
        output A, B, OP, RST;
    endclocking

    clocking mon_cb @(posedge CLK);
        default input #1step output #2;
        input A, B, OP, RST, Zero_Flag, Arithm_FLag, Logic_Flag, Carry_Flag, Result;
    endclocking

    modport DRIVER  (clocking drv_cb);
    modport MONITOR (clocking mon_cb);

endinterface