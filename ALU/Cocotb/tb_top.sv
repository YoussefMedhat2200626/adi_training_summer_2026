module tb_top;
    logic clk;
    logic rst_n;

    // Instantiate the interface
    alu_if vif(
        .clk(clk),
        .rst_n(rst_n)
    );

    // Instantiate the DUT and pass the interface to it
    alu #(.WIDTH(8)) dut (
        .vif(vif)
    );
endmodule`