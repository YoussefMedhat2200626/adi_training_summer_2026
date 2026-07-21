library verilog;
use verilog.vl_types.all;
entity alu_if is
    generic(
        WIDTH           : integer := 4
    );
    port(
        CLK             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end alu_if;
