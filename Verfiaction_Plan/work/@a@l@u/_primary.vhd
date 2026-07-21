library verilog;
use verilog.vl_types.all;
entity ALU is
    generic(
        WIDTH           : integer := 4
    );
    port(
        A               : in     vl_logic_vector;
        B               : in     vl_logic_vector;
        OP              : in     vl_logic_vector(1 downto 0);
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        Zero_Flag       : out    vl_logic;
        Arithm_FLag     : out    vl_logic;
        Logic_Flag      : out    vl_logic;
        Carry_Flag      : out    vl_logic;
        Result          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
end ALU;
