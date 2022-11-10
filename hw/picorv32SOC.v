module picorv32SOC (
    input wire eclk,
    input wire erstn,

    //UART interface
    input  wire uart_rx,
    output wire uart_tx
);

  /*---rPLL---*/
  wire pll_lock;
  wire uclk;
  wire urstn;

  /*---picorv32---*/
  wire rv_mem_valid;
  wire rv_mem_instr;
  wire rv_mem_ready;
  wire [32-1:0] rv_mem_addr;
  wire [32-1:0] rv_mem_wdata;
  wire [4-1:0] rv_mem_wstrb;
  wire [32-1:0] rv_mem_rdata;

  wire [32-1:0] rv_irq;
  wire [32-1:0] rv_eoi;

  /*---RAM---*/
  wire ram_mem_valid;
  wire ram_mem_ready;
  wire [32-1:0] ram_mem_addr;
  wire [32-1:0] ram_mem_wdata;
  wire [4-1:0] ram_mem_wstrb;
  wire [32-1:0] ram_mem_rdata;

  /*---UART---*/
  wire uart_mem_valid;
  wire uart_mem_ready;
  wire [32-1:0] uart_mem_addr;
  wire [32-1:0] uart_mem_wdata;
  wire [4-1:0] uart_mem_wstrb;
  wire [32-1:0] uart_mem_rdata;

  /*---AES---*/
  wire aes_mem_valid;
  wire aes_mem_ready;
  wire [32-1:0] aes_mem_addr;
  wire [32-1:0] aes_mem_wdata;
  wire [4-1:0] aes_mem_wstrb;
  wire [32-1:0] aes_mem_rdata;

  wire key_expand_done;
  wire cipher_done;

  /*---rPLL---*/
  Gowin_rPLL rPLL_inst (
    .clkout(uclk),
    .lock(pll_lock),
    .clkin(eclk)
  );

  /*---sync_e2u---*/
  sync_e2u sync_e2u_inst(
    .uclk(uclk),
    .erstn(erstn),
    .pll_lock(pll_lock),
    .urstn(urstn)
  );

  /*---Picorv32--*/
  picorv32 #(
      .TWO_CYCLE_COMPARE(1),  //Add a FF when doing the branch instruction
      .TWO_CYCLE_ALU(1),  //Add a FF when doing the instruction using the ALU
      .COMPRESSED_ISA(1),  //Enable compressed ISA
      .ENABLE_PCPI(1), //Enable PCPI
      .ENABLE_MUL(1),  //Enable Mult insturction
      .ENABLE_DIV(1),  //Enable Div insturction
      .ENABLE_IRQ(1),  //Enable IQR
      .PROGADDR_RESET(32'h00000000), //Boot addr
      .PROGADDR_IRQ(32'h00000004),  //IRQ handler addr
      .STACKADDR(32'h00002000)  //Stack bottom
  ) rv32_inst (
      .clk(uclk),
      .resetn(urstn),
      .trap(),
      .mem_valid(rv_mem_valid),
      .mem_instr(rv_mem_instr),
      .mem_ready(rv_mem_ready),
      .mem_addr(rv_mem_addr),
      .mem_wdata(rv_mem_wdata),
      .mem_wstrb(rv_mem_wstrb),
      .mem_rdata(rv_mem_rdata),
      .irq(rv_irq),
      .eoi(rv_eoi)
  );
  assign rv_irq = {key_expand_done, cipher_done, 3'b0};

  /*
    0x00000000 RAM
    0x20000000 Peripheral
      0x20000000 UART
      0x28000000 AES
  */
  Interconnect Interconnect_inst (
      .s_mem_valid(rv_mem_valid),
      .s_mem_ready(rv_mem_ready),
      .s_mem_addr (rv_mem_addr),
      .s_mem_wdata(rv_mem_wdata),
      .s_mem_wstrb(rv_mem_wstrb),
      .s_mem_rdata(rv_mem_rdata),

      .m_mem_valid0(ram_mem_valid),
      .m_mem_ready0(ram_mem_ready),
      .m_mem_addr0 (ram_mem_addr),
      .m_mem_wdata0(ram_mem_wdata),
      .m_mem_wstrb0(ram_mem_wstrb),
      .m_mem_rdata0(ram_mem_rdata),

      .m_mem_valid1(),
      .m_mem_ready1(1'b1),
      .m_mem_addr1 (),
      .m_mem_wdata1(),
      .m_mem_wstrb1(),
      .m_mem_rdata1(32'h00000000),

      .m_mem_valid2(uart_mem_valid),
      .m_mem_ready2(uart_mem_ready),
      .m_mem_addr2 (uart_mem_addr),
      .m_mem_wdata2(uart_mem_wdata),
      .m_mem_wstrb2(uart_mem_wstrb),
      .m_mem_rdata2(uart_mem_rdata),

      .m_mem_valid3(aes_mem_valid),
      .m_mem_ready3(aes_mem_ready),
      .m_mem_addr3 (aes_mem_addr),
      .m_mem_wdata3(aes_mem_wdata),
      .m_mem_wstrb3(aes_mem_wstrb),
      .m_mem_rdata3(aes_mem_rdata),

      .m_mem_valid4(),
      .m_mem_ready4(1'b1),
      .m_mem_addr4 (),
      .m_mem_wdata4(),
      .m_mem_wstrb4(),
      .m_mem_rdata4(32'h00000000),

      .m_mem_valid5(),
      .m_mem_ready5(1'b1),
      .m_mem_addr5 (),
      .m_mem_wdata5(),
      .m_mem_wstrb5(),
      .m_mem_rdata5(32'h00000000),

      .m_mem_valid6(),
      .m_mem_ready6(1'b1),
      .m_mem_addr6 (),
      .m_mem_wdata6(),
      .m_mem_wstrb6(),
      .m_mem_rdata6(32'h00000000)
  );

  RAM_mem RAM_mem_inst (
      .clk(uclk),
      .rstn(urstn),
      .mem_valid(ram_mem_valid),
      .mem_ready(ram_mem_ready),
      .mem_addr(ram_mem_addr),
      .mem_wdata(ram_mem_wdata),
      .mem_wstrb(ram_mem_wstrb),
      .mem_rdata(ram_mem_rdata)
  );

  UART_mem UART_mem_inst (
      .clk(uclk),
      .rstn(urstn),
      .uart_rx(uart_rx),
      .uart_tx(uart_tx),
      .mem_valid(uart_mem_valid),
      .mem_ready(uart_mem_ready),
      .mem_addr(uart_mem_addr),
      .mem_wdata(uart_mem_wdata),
      .mem_wstrb(uart_mem_wstrb),
      .mem_rdata(uart_mem_rdata)
  );

  AES_mem AES_mem_inst(
    .clk(uclk),
    .rstn(urstn),
    .mem_valid(aes_mem_valid),
    .mem_ready(aes_mem_ready),
    .mem_addr(aes_mem_addr),
    .mem_wdata(aes_mem_wdata),
    .mem_wstrb(aes_mem_wstrb),
    .mem_rdata(aes_mem_rdata),
    .key_expand_done(key_expand_done),
    .cipher_done(cipher_done)
  );

endmodule  //picorv32SOC
