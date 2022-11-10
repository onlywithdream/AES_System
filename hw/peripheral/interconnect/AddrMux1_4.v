module AddrMux1_4 #(
    parameter [32-1:0] BaseAddr0 = 32'h00000000,
    parameter [32-1:0] AddrMask0 = 32'h00000000,
    parameter [32-1:0] BaseAddr1 = 32'h00000000,
    parameter [32-1:0] AddrMask1 = 32'h00000000,
    parameter [32-1:0] BaseAddr2 = 32'h00000000,
    parameter [32-1:0] AddrMask2 = 32'h00000000,
    parameter [32-1:0] BaseAddr3 = 32'h00000000,
    parameter [32-1:0] AddrMask3 = 32'h00000000
) (
    //Slave
    input  wire s_mem_valid,
    output wire s_mem_ready,

    input  wire [32-1:0] s_mem_addr,
    input  wire [32-1:0] s_mem_wdata,
    input  wire [ 4-1:0] s_mem_wstrb,
    output wire [32-1:0] s_mem_rdata,

    //Master0
    output wire m_mem_valid0,
    input  wire m_mem_ready0,

    output wire [32-1:0] m_mem_addr0,
    output wire [32-1:0] m_mem_wdata0,
    output wire [ 4-1:0] m_mem_wstrb0,
    input  wire [32-1:0] m_mem_rdata0,

    //Master1
    output wire m_mem_valid1,
    input  wire m_mem_ready1,

    output wire [32-1:0] m_mem_addr1,
    output wire [32-1:0] m_mem_wdata1,
    output wire [ 4-1:0] m_mem_wstrb1,
    input  wire [32-1:0] m_mem_rdata1,

    //Master2
    output wire m_mem_valid2,
    input  wire m_mem_ready2,

    output wire [32-1:0] m_mem_addr2,
    output wire [32-1:0] m_mem_wdata2,
    output wire [ 4-1:0] m_mem_wstrb2,
    input  wire [32-1:0] m_mem_rdata2,

    //Master3
    output wire m_mem_valid3,
    input  wire m_mem_ready3,

    output wire [32-1:0] m_mem_addr3,
    output wire [32-1:0] m_mem_wdata3,
    output wire [ 4-1:0] m_mem_wstrb3,
    input  wire [32-1:0] m_mem_rdata3
);

  wire m0_sel;
  wire m1_sel;
  wire m2_sel;
  wire m3_sel;

  //Slave
  reg  s_mem_ready_r;
  reg  s_mem_rdata_r;

  assign s_mem_ready = |{{m0_sel, m1_sel, m2_sel, m3_sel} &
                         {m_mem_ready0, m_mem_ready1, m_mem_ready2, m_mem_ready3}};
  assign s_mem_rdata = {{32{m0_sel}} & m_mem_rdata0} |
                       {{32{m1_sel}} & m_mem_rdata1} |
                       {{32{m2_sel}} & m_mem_rdata2} |
                       {{32{m3_sel}} & m_mem_rdata3};

  //Master0
  assign m0_sel = ~|((BaseAddr0 ^ s_mem_addr) & AddrMask0);
  assign m_mem_valid0 = m0_sel & s_mem_valid;
  assign m_mem_addr0 = s_mem_addr;
  assign m_mem_wdata0 = s_mem_wdata;
  assign m_mem_wstrb0 = s_mem_wstrb;

  //Master1
  assign m1_sel = ~|((BaseAddr1 ^ s_mem_addr) & AddrMask1);
  assign m_mem_valid1 = m1_sel & s_mem_valid;
  assign m_mem_addr1 = s_mem_addr;
  assign m_mem_wdata1 = s_mem_wdata;
  assign m_mem_wstrb1 = s_mem_wstrb;

  //Master2
  assign m2_sel = ~|((BaseAddr2 ^ s_mem_addr) & AddrMask2);
  assign m_mem_valid2 = m2_sel & s_mem_valid;
  assign m_mem_addr2 = s_mem_addr;
  assign m_mem_wdata2 = s_mem_wdata;
  assign m_mem_wstrb2 = s_mem_wstrb;

  //Master3
  assign m3_sel = ~|((BaseAddr3 ^ s_mem_addr) & AddrMask3);
  assign m_mem_valid3 = m3_sel & s_mem_valid;
  assign m_mem_addr3 = s_mem_addr;
  assign m_mem_wdata3 = s_mem_wdata;
  assign m_mem_wstrb3 = s_mem_wstrb;

endmodule  //AddrMux1_4
