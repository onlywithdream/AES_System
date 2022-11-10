/*
    0x00000000 Master0
    0x10000000 Master1
    0x20000000 Master2
    0x28000000 Master3
    0x30000000 Master4
    0x38000000 Master5
    0x40000000 Master6
*/
module Interconnect (
    input wire s_mem_valid,
    output wire s_mem_ready,
    input wire [32-1:0] s_mem_addr,
    input wire [32-1:0] s_mem_wdata,
    input wire [4-1:0] s_mem_wstrb,
    output wire [32-1:0] s_mem_rdata,

    output wire m_mem_valid0,
    input wire m_mem_ready0,
    output wire [32-1:0] m_mem_addr0,
    output wire [32-1:0] m_mem_wdata0,
    output wire [4-1:0] m_mem_wstrb0,
    input wire [32-1:0] m_mem_rdata0,

    output wire m_mem_valid1,
    input wire m_mem_ready1,
    output wire [32-1:0] m_mem_addr1,
    output wire [32-1:0] m_mem_wdata1,
    output wire [4-1:0] m_mem_wstrb1,
    input wire [32-1:0] m_mem_rdata1,

    output wire m_mem_valid2,
    input wire m_mem_ready2,
    output wire [32-1:0] m_mem_addr2,
    output wire [32-1:0] m_mem_wdata2,
    output wire [4-1:0] m_mem_wstrb2,
    input wire [32-1:0] m_mem_rdata2,

    output wire m_mem_valid3,
    input wire m_mem_ready3,
    output wire [32-1:0] m_mem_addr3,
    output wire [32-1:0] m_mem_wdata3,
    output wire [4-1:0] m_mem_wstrb3,
    input wire [32-1:0] m_mem_rdata3,

    output wire m_mem_valid4,
    input wire m_mem_ready4,
    output wire [32-1:0] m_mem_addr4,
    output wire [32-1:0] m_mem_wdata4,
    output wire [4-1:0] m_mem_wstrb4,
    input wire [32-1:0] m_mem_rdata4,

    output wire m_mem_valid5,
    input wire m_mem_ready5,
    output wire [32-1:0] m_mem_addr5,
    output wire [32-1:0] m_mem_wdata5,
    output wire [4-1:0] m_mem_wstrb5,
    input wire [32-1:0] m_mem_rdata5,

    output wire m_mem_valid6,
    input wire m_mem_ready6,
    output wire [32-1:0] m_mem_addr6,
    output wire [32-1:0] m_mem_wdata6,
    output wire [4-1:0] m_mem_wstrb6,
    input wire [32-1:0] m_mem_rdata6
);

  /*---Peripheral---*/
  wire peripheral_mem_valid;
  wire peripheral_mem_ready;
  wire [32-1:0] peripheral_mem_addr;
  wire [32-1:0] peripheral_mem_wdata;
  wire [4-1:0] peripheral_mem_wstrb;
  wire [32-1:0] peripheral_mem_rdata;

  AddrMux1_4 #(
      .BaseAddr0(32'h00000000),
      .AddrMask0(32'h70000000),
      .BaseAddr1(32'h10000000),
      .AddrMask1(32'h70000000),
      .BaseAddr2(32'h20000000),
      .AddrMask2(32'h60000000),
      .BaseAddr3(32'h40000000),
      .AddrMask3(32'h40000000)
  ) global_AddrMux1_4_inst (
      .s_mem_valid(s_mem_valid),
      .s_mem_ready(s_mem_ready),
      .s_mem_addr (s_mem_addr),
      .s_mem_wdata(s_mem_wdata),
      .s_mem_wstrb(s_mem_wstrb),
      .s_mem_rdata(s_mem_rdata),

      .m_mem_valid0(m_mem_valid0),
      .m_mem_ready0(m_mem_ready0),
      .m_mem_addr0 (m_mem_addr0),
      .m_mem_wdata0(m_mem_wdata0),
      .m_mem_wstrb0(m_mem_wstrb0),
      .m_mem_rdata0(m_mem_rdata0),

      .m_mem_valid1(m_mem_valid1),
      .m_mem_ready1(m_mem_ready1),
      .m_mem_addr1 (m_mem_addr1),
      .m_mem_wdata1(m_mem_wdata1),
      .m_mem_wstrb1(m_mem_wstrb1),
      .m_mem_rdata1(m_mem_rdata1),

      .m_mem_valid2(peripheral_mem_valid),
      .m_mem_ready2(peripheral_mem_ready),
      .m_mem_addr2 (peripheral_mem_addr),
      .m_mem_wdata2(peripheral_mem_wdata),
      .m_mem_wstrb2(peripheral_mem_wstrb),
      .m_mem_rdata2(peripheral_mem_rdata),

      .m_mem_valid3(m_mem_valid6),
      .m_mem_ready3(m_mem_ready6),
      .m_mem_addr3 (m_mem_addr6),
      .m_mem_wdata3(m_mem_wdata6),
      .m_mem_wstrb3(m_mem_wstrb6),
      .m_mem_rdata3(m_mem_rdata6)
  );

  AddrMux1_4 #(
      .BaseAddr0(32'h20000000),
      .AddrMask0(32'h18000000),
      .BaseAddr1(32'h28000000),
      .AddrMask1(32'h18000000),
      .BaseAddr2(32'h30000000),
      .AddrMask2(32'h18000000),
      .BaseAddr3(32'h38000000),
      .AddrMask3(32'h18000000)
  ) peripheral_AddrMux1_4_inst (
      .s_mem_valid(peripheral_mem_valid),
      .s_mem_ready(peripheral_mem_ready),
      .s_mem_addr (peripheral_mem_addr),
      .s_mem_wdata(peripheral_mem_wdata),
      .s_mem_wstrb(peripheral_mem_wstrb),
      .s_mem_rdata(peripheral_mem_rdata),

      .m_mem_valid0(m_mem_valid2),
      .m_mem_ready0(m_mem_ready2),
      .m_mem_addr0 (m_mem_addr2),
      .m_mem_wdata0(m_mem_wdata2),
      .m_mem_wstrb0(m_mem_wstrb2),
      .m_mem_rdata0(m_mem_rdata2),

      .m_mem_valid1(m_mem_valid3),
      .m_mem_ready1(m_mem_ready3),
      .m_mem_addr1 (m_mem_addr3),
      .m_mem_wdata1(m_mem_wdata3),
      .m_mem_wstrb1(m_mem_wstrb3),
      .m_mem_rdata1(m_mem_rdata3),

      .m_mem_valid2(m_mem_valid4),
      .m_mem_ready2(m_mem_ready4),
      .m_mem_addr2 (m_mem_addr4),
      .m_mem_wdata2(m_mem_wdata4),
      .m_mem_wstrb2(m_mem_wstrb4),
      .m_mem_rdata2(m_mem_rdata4),

      .m_mem_valid3(m_mem_valid5),
      .m_mem_ready3(m_mem_ready5),
      .m_mem_addr3 (m_mem_addr5),
      .m_mem_wdata3(m_mem_wdata5),
      .m_mem_wstrb3(m_mem_wstrb5),
      .m_mem_rdata3(m_mem_rdata5)
  );

endmodule  //Interconnect
