module ahb_system_wrapper #(
    parameter MEM_BASE_ADDR      = 32'h0000_0000,
    parameter MEM_SIZE_PER_SLAVE = 1024
)(
    input  logic        hclk,
    input  logic        hresetn,

    // Microcontroller Request Interface 
    input  logic        i_req_valid,
    input  logic        i_req_write,
    input  logic [31:0] i_req_addr,
    input  logic [31:0] i_req_wdata,
    input  logic [2:0]  i_req_size,
    input  logic [2:0]  i_req_burst,
    input  logic        i_req_busy,
    input  logic [3:0]  i_req_prot,
    input  logic        i_req_lock,

    // Microcontroller Feedback & Response Interface
    output logic        o_req_ready,
    output logic        o_resp_valid,
    output logic [31:0] o_resp_rdata,
    output logic        o_resp_error
);

    // Master AHB Bus Signals
    logic [31:0] m_haddr;
    logic [1:0]  m_htrans;
    logic        m_hwrite;
    logic [2:0]  m_hsize;
    logic [2:0]  m_hburst;
    logic [3:0]  m_hprot;
    logic        m_hmastlock;
    logic [31:0] m_hwdata;
    
    // signals from Interconnect back to Master
    logic [31:0] m_hrdata;
    logic        m_hready;
    logic        m_hresp;

    // Slave Buses
    logic        s0_hsel,       s1_hsel,       s2_hsel;
    logic [31:0] s0_hrdata,     s1_hrdata,     s2_hrdata;
    logic        s0_hready_out, s1_hready_out, s2_hready_out;
    logic        s0_hresp,      s1_hresp,      s2_hresp;

    // AHB Master Instantiation
    ahb_master_fsm u_master (
        .hclk         (hclk),
        .hresetn      (hresetn),
        
        .i_req_valid  (i_req_valid),
        .i_req_write  (i_req_write),
        .i_req_addr   (i_req_addr),
        .i_req_wdata  (i_req_wdata),
        .i_req_size   (i_req_size),
        .i_req_burst  (i_req_burst),
        .i_req_busy   (i_req_busy),
        .i_req_prot   (i_req_prot),
        .i_req_lock   (i_req_lock),
        
        .o_req_ready  (o_req_ready),
        .o_resp_valid (o_resp_valid),
        .o_resp_rdata (o_resp_rdata),
        .o_resp_error (o_resp_error),

        .haddr        (m_haddr),
        .htrans       (m_htrans),
        .hwrite       (m_hwrite),
        .hsize        (m_hsize),
        .hburst       (m_hburst),
        .hprot        (m_hprot),
        .hmastlock    (m_hmastlock),
        .hwdata       (m_hwdata),
        
        .hrdata       (m_hrdata),
        .hready       (m_hready),
        .hresp        (m_hresp)
    );

    // AHB Interconnect Instantiation
    ahb_interconnect #(
        .MEM_BASE_ADDR      (MEM_BASE_ADDR),
        .MEM_SIZE_PER_SLAVE (MEM_SIZE_PER_SLAVE)
    ) u_interconnect (
        .hclk          (hclk),
        .hresetn       (hresetn),

        .haddr         (m_haddr),
        .htrans        (m_htrans),

        .hrdata_s0     (s0_hrdata),     .hrdata_s1     (s1_hrdata),     .hrdata_s2     (s2_hrdata),
        .hready_out_s0 (s0_hready_out), .hready_out_s1 (s1_hready_out), .hready_out_s2 (s2_hready_out),
        .hresp_s0      (s0_hresp),      .hresp_s1      (s1_hresp),      .hresp_s2      (s2_hresp),

        .hsel_s0       (s0_hsel),       .hsel_s1       (s1_hsel),       .hsel_s2       (s2_hsel),

        .hrdata        (m_hrdata),
        .hready        (m_hready),
        .hresp         (m_hresp)
    );

    // AHB Slave Instantiations
    
    // SLAVE 0
    ahb_slave_memory #(.MEM_SIZE(MEM_SIZE_PER_SLAVE)) u_slave_0 (
        .hclk         (hclk),
        .hresetn      (hresetn),
        .hsel         (s0_hsel),
        // Subtract offset so local memory index starts at 0
        .haddr        (m_haddr - MEM_BASE_ADDR), 
        .htrans       (m_htrans),
        .hwrite       (m_hwrite),
        .hsize        (m_hsize),
        .hburst       (m_hburst),
        .hprot        (m_hprot),
        .hmastlock    (m_hmastlock),
        .hwdata       (m_hwdata),
        .hready_in    (m_hready),
        
        .hrdata       (s0_hrdata),
        .hready_out   (s0_hready_out),
        .hresp        (s0_hresp)
    );

    // SLAVE 1
    ahb_slave_memory #(.MEM_SIZE(MEM_SIZE_PER_SLAVE)) u_slave_1 (
        .hclk         (hclk),
        .hresetn      (hresetn),
        .hsel         (s1_hsel),
        .haddr        (m_haddr - (MEM_BASE_ADDR + MEM_SIZE_PER_SLAVE)),
        .htrans       (m_htrans),
        .hwrite       (m_hwrite),
        .hsize        (m_hsize),
        .hburst       (m_hburst),
        .hprot        (m_hprot),
        .hmastlock    (m_hmastlock),
        .hwdata       (m_hwdata),
        .hready_in    (m_hready),
        
        .hrdata       (s1_hrdata),
        .hready_out   (s1_hready_out),
        .hresp        (s1_hresp)
    );

    // SLAVE 2
    ahb_slave_memory #(.MEM_SIZE(MEM_SIZE_PER_SLAVE)) u_slave_2 (
        .hclk         (hclk),
        .hresetn      (hresetn),
        .hsel         (s2_hsel),
        .haddr        (m_haddr - (MEM_BASE_ADDR + 2*MEM_SIZE_PER_SLAVE)),
        .htrans       (m_htrans),
        .hwrite       (m_hwrite),
        .hsize        (m_hsize),
        .hburst       (m_hburst),
        .hprot        (m_hprot),
        .hmastlock    (m_hmastlock),
        .hwdata       (m_hwdata),
        .hready_in    (m_hready),
        
        .hrdata       (s2_hrdata),
        .hready_out   (s2_hready_out),
        .hresp        (s2_hresp)
    );
endmodule