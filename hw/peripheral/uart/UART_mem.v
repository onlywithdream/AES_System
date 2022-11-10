/*
    UART_DIV  0x00000000 4B
    UART_DATA 0x00000004 4B
*/

module UART_mem (
    input wire clk,
    input wire rstn,

    input  wire uart_rx,
    output wire uart_tx,

    input  wire mem_valid,
    output wire mem_ready,

    input  wire [32-1:0] mem_addr,
    input  wire [32-1:0] mem_wdata,
    input  wire [ 4-1:0] mem_wstrb,
    output wire [32-1:0] mem_rdata
);

  wire reg_div_sel;
  wire reg_dat_sel;

  wire [4-1:0] reg_div_we;
  wire reg_dat_we;
  wire reg_dat_re;

  wire [32-1:0] reg_div_do;
  wire [32-1:0] reg_dat_do;
  wire reg_dat_wait;

  assign reg_div_sel = mem_valid & ~mem_addr[2];
  assign reg_dat_sel = mem_valid & mem_addr[2];

  assign reg_div_we  = {4{reg_div_sel}} & mem_wstrb;
  assign reg_dat_we  = reg_dat_sel & mem_wstrb[0];
  assign reg_dat_re  = reg_dat_sel & (~|mem_wstrb);

  simpleuart simpleuart_inst (
      .clk(clk),
      .resetn(rstn),

      .ser_tx(uart_tx),
      .ser_rx(uart_rx),

      .reg_div_we(reg_div_we),
      .reg_div_di(mem_wdata),
      .reg_div_do(reg_div_do),

      .reg_dat_we  (reg_dat_we),
      .reg_dat_re  (reg_dat_re),
      .reg_dat_di  (mem_wdata),
      .reg_dat_do  (reg_dat_do),
      .reg_dat_wait(reg_dat_wait)
  );

  assign mem_rdata = mem_addr[2] ? reg_dat_do : reg_div_do;
  assign mem_ready = reg_div_sel | (reg_dat_sel & (~reg_dat_wait));

endmodule  //UART_mem
