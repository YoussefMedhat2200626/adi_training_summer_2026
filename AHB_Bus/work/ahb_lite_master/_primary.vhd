library verilog;
use verilog.vl_types.all;
entity ahb_lite_master is
    generic(
        AW              : integer := 32;
        DW              : integer := 32;
        MAX_BEATS       : integer := 16
    );
    port(
        HCLK            : in     vl_logic;
        HRESETn         : in     vl_logic;
        HADDR           : out    vl_logic_vector;
        HWRITE          : out    vl_logic;
        HSIZE           : out    vl_logic_vector(2 downto 0);
        HBURST          : out    vl_logic_vector(2 downto 0);
        HTRANS          : out    vl_logic_vector(1 downto 0);
        HWDATA          : out    vl_logic_vector;
        HREADY          : in     vl_logic;
        HRESP           : in     vl_logic;
        HRDATA          : in     vl_logic_vector;
        start           : in     vl_logic;
        wr_en           : in     vl_logic;
        start_addr      : in     vl_logic_vector;
        burst_type      : in     vl_logic_vector(2 downto 0);
        wdata_bus       : in     vl_logic_vector;
        busy            : out    vl_logic;
        done            : out    vl_logic;
        error           : out    vl_logic;
        rdata_valid     : out    vl_logic;
        rdata_out       : out    vl_logic_vector;
        rbeat_num       : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
    attribute mti_svvh_generic_type of DW : constant is 1;
    attribute mti_svvh_generic_type of MAX_BEATS : constant is 1;
end ahb_lite_master;
