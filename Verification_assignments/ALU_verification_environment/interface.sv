`ifndef ALU_IF_SV
`define ALU_IF_SV
interface alu_if #(parameter n = 4) (
input reg CLK
);

    logic RST;
    logic [n-1:0] A;
    logic [n-1:0] B;
    logic [1:0]   OpSel;
    logic [n-1:0] Out;
    logic         Carry;

    modport DUT_mp (
        input  CLK, RST, A, B, OpSel,
        output Out, Carry
    );

    modport TB_mp (
        output CLK, RST, A, B, OpSel,
        input  Out, Carry
    );

endinterface

`endif