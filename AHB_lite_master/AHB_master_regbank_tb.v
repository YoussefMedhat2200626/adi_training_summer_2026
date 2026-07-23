`timescale 1ns/1ps
module AHB_master_tb;
    reg Hclk, HRESTn, start, stall, burst, wrtrd_sel, force_error;
    reg [1:0] size_in;
    reg [31:0] datawrite, addr;
    reg [3:0] wait_cycles;
    wire [31:0] Haddr, Hwdata, HRdata;
    wire Hwrite, Hready, Hresp, Hmastlock;
    wire [2:0] Hsize, Hburst;
    wire [1:0] Htrans;
    wire [3:0] Hprot;

    integer errors, i;
    reg [31:0] result;
    reg [31:0] base;               
    reg [31:0] d0, d1, d2, d3;   
    reg [31:0] addr_step;   

    initial Hclk = 0;
    always #5 Hclk = ~Hclk;

    AHB_master dut (.Hclk(Hclk), .HRESTn(HRESTn), .start(start), .stall(stall), .burst(burst), .size_in(size_in),.Hresp(Hresp), .Hready(Hready), .HRdata(HRdata), 
    .datawrite(datawrite), .wrtrd_sel(wrtrd_sel), .addr(addr), .Haddr(Haddr), .Hwrite(Hwrite), .Hsize(Hsize), .Hburst(Hburst), .Htrans(Htrans), .Hwdata(Hwdata), .Hprot(Hprot), .Hmastlock(Hmastlock));

    regbank slave (.Hclk(Hclk), .HRESTn(HRESTn), .Haddr(Haddr), .Hwrite(Hwrite), .Htrans(Htrans), .Hwdata(Hwdata), .wait_cycles(wait_cycles), .force_error(force_error), 
    .Hready(Hready), .Hresp(Hresp), .HRdata(HRdata));

    initial begin
        HRESTn = 0; 
        start = 0; 
        stall = 0; 
        burst = 0; 
        size_in = 2'b10;
        datawrite = 0; 
        wrtrd_sel = 0; 
        addr = 0; 
        wait_cycles = 0; 
        force_error = 0;
        errors = 0;
        repeat (3) @(posedge Hclk);
        HRESTn = 1;
        @(posedge Hclk);
        
        addr_step = (size_in == 2'b00) ? 32'd1 : (size_in == 2'b01) ? 32'd2 : 32'd4;
        $display("random single write/read");
        for (i = 0; i < 30; i = i + 1) begin
            addr        = $urandom_range(0, 15) * 4;
            datawrite   = $urandom;
            wait_cycles = $urandom_range(0, 3);
            wrtrd_sel = 1; 
            burst = 0; 
            start = 1;
            @(posedge Hclk);
            start = 0;
            @(posedge Hclk);
            while (!Hready) @(posedge Hclk);
            @(posedge Hclk);
            if (Htrans !== 2'b00) begin
                $display("Fail: expected IDLE after write but Htrans=%b", Htrans);
                errors = errors + 1;
            end
 
            wait_cycles = $urandom_range(0, 3);
            wrtrd_sel = 0; 
            burst = 0; 
            start = 1;
            @(posedge Hclk);
            start = 0;
            @(posedge Hclk);
            while (!Hready) @(posedge Hclk);
            @(posedge Hclk);
            result = HRdata;
            if (Htrans !== 2'b00) begin
                $display("Fail: expected IDLE after read but Htrans=%b", Htrans);
                errors = errors + 1;
            end
            if (result !== datawrite) begin
                $display("Fail: addr=0x%0h expected=%h got=%h", addr, datawrite, result);
                errors = errors + 1;
            end
        end
        wait_cycles = 0;
 
        $display("4-beat burst write, no stall");

        base = $urandom_range(0, 12) * 4;      
        d0 = $urandom; d1 = $urandom; d2 = $urandom; d3 = $urandom;

        addr = base; 
        datawrite = d0; 
        wrtrd_sel = 1;
        burst = 1; 
        stall = 0; 
        start = 1;
        @(posedge Hclk);                     
        while (!Hready) @(posedge Hclk);
        start = 0; 
        datawrite = d1;
        @(posedge Hclk);                    

        while (!Hready) @(posedge Hclk);
        datawrite = d2;
        @(posedge Hclk);                   

        while (!Hready) @(posedge Hclk);
        datawrite = d3;
        @(posedge Hclk);                    

        while (!Hready) @(posedge Hclk);
        burst = 0; 
        start = 0;
        @(posedge Hclk);                     
        while (!Hready) @(posedge Hclk);
        @(posedge Hclk);
        if (Htrans !== 2'b00) begin
            $display("Fail: expected IDLE after burst write but Htrans=%b", Htrans);
            errors = errors + 1;
        end

        addr = base; 
        wrtrd_sel = 0; 
        burst = 0; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); @(posedge Hclk);
        if (HRdata !== d0) begin
            $display("Fail: addr=0x%0h expected=%h got=%h", base, d0, HRdata); 
            errors = errors + 1;
        end

        addr = addr + addr_step; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); @(posedge Hclk);
        if (HRdata !== d1) begin
            $display("Fail: addr=0x%0h expected=%h got=%h", addr + addr_step, d1, HRdata); 
            errors = errors + 1;
        end

        addr = addr + addr_step; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); 
        @(posedge Hclk);
        if (HRdata !== d2) begin
            $display("Fail: addr=0x%0h expected=%h got=%h",addr + addr_step, d2, HRdata); 
            errors = errors + 1;
        end

        addr = addr + addr_step; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); 
        @(posedge Hclk);
        if (HRdata !== d3) begin
            $display("Fail: addr=0x%0h expected=%h got=%h", addr + addr_step, d3, HRdata); errors = errors + 1;
        end
        

        $display("3-beat burst write with one BUSY beat");

        base = $urandom_range(0, 12) * 4;
        d0 = $urandom; d1 = $urandom; d2 = $urandom;
        addr = base; 
        datawrite = d0; 
        wrtrd_sel = 1;
        burst = 1; 
        stall = 0; 
        start = 1;
        @(posedge Hclk);                    
        while (!Hready) @(posedge Hclk);
        start = 0; 

        datawrite = d1;
        @(posedge Hclk);                     

        while (!Hready) @(posedge Hclk);
        stall = 1;
        @(posedge Hclk);                    

        while (!Hready) @(posedge Hclk);
        stall = 0; 
        datawrite = d2;
        @(posedge Hclk);  

        while (!Hready) @(posedge Hclk);
        burst = 0;
        start = 0;
        @(posedge Hclk);                    

        while (!Hready) @(posedge Hclk);
        @(posedge Hclk);
        if (Htrans !== 2'b00) begin
            $display("Fail: expected IDLE after stalled burst but Htrans=%b", Htrans);
            errors = errors + 1;
        end

        addr = base; 
        wrtrd_sel = 0; 
        burst = 0; 
        start = 1;
        @(posedge Hclk); 
        start = 0;
        @(posedge Hclk);

        while (!Hready) @(posedge Hclk); 
        @(posedge Hclk);
        if (HRdata !== d0) begin
            $display("Fail: addr=0x%0h expected=%h got=%h", base, d0, HRdata); 
            errors = errors + 1;
        end

        addr = addr + addr_step; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); 
        @(posedge Hclk);
        if (HRdata !== d1) begin
            $display("fail: addr=0x%0h expected=%h got=%h", addr + addr_step, d1, HRdata); 
            errors = errors + 1;
        end

        addr = addr + addr_step; 
        start = 1;
        @(posedge Hclk); 
        start = 0; 
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk); 
        @(posedge Hclk);
        if (HRdata !== d2) begin
            $display("fail: addr=0x%0h expected=%h got=%h", addr + addr_step, d2, HRdata); 
            errors = errors + 1;
        end

        $display("Test error response handling (force_error = 1)");
        
        addr        = 32'h04;
        datawrite   = 32'hDEAD_BEEF;
        wrtrd_sel   = 1;
        force_error = 1; 
        start       = 1;
        
        @(posedge Hclk);
        start = 0;
        @(posedge Hclk);
        while (!Hready) @(posedge Hclk);
        
        
        if (Hresp !== 1'b1) begin
            $display("Fail: Expected Hresp=1 but got Hresp=%b", Hresp);
            errors = errors + 1;
        end
        
        @(posedge Hclk);
        if (Htrans !== 2'b00) begin
            $display("Fail: Master failed to return to IDLE after error! Htrans=%b", Htrans);
            errors = errors + 1;
        end

        force_error = 0;

        $display("Test complete: %0d mismatches", errors);
        $stop;
    end

endmodule