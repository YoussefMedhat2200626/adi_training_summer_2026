library verilog;
use verilog.vl_types.all;
entity ahb_lite_slave_model is
    generic(
        AW              : integer := 32;
        DW              : integer := 32;
        MEM_WDS         : integer := 64
    );
    port(
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        HSEL            : in     vl_logic;
        HADDR           : in     vl_logic_vector;
        HWRITE          : in     vl_logic;
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HWDATA          : in     vl_logic_vector;
        HREADY          : in     vl_logic;
        HREADYOUT       : out    vl_logic;
        HRESP           : out    vl_logic;
        HRDATA          : out    vl_logic_vector;
        wait_states     : in     vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
    attribute mti_svvh_generic_type of DW : constant is 1;
    attribute mti_svvh_generic_type of MEM_WDS : constant is 1;
end ahb_lite_slave_model;
