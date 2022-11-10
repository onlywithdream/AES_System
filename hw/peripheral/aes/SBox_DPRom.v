module SBox_DPRom #(
    parameter ReadMode = 1'b0
)(
    input wire clk,

    input  wire [9-1:0] a_raddr,
    output wire [8-1:0] a_rdata,

    input  wire [9-1:0] b_raddr,
    output wire [8-1:0] b_rdata
);

  Gowin_SBox_DPRam #(
      .ReadMode(ReadMode)
  )Gowin_SBox_DPRam_inst(
      .douta(a_rdata),
      .doutb(b_rdata),
      .clka(clk),
      .ocea(1'b1),
      .cea(1'b1),
      .reseta(1'b0),
      .wrea(1'b0),
      .clkb(clk),
      .oceb(1'b1),
      .ceb(1'b1),
      .resetb(1'b0),
      .wreb(1'b0),
      .ada(a_raddr),
      .dina(8'h00),
      .adb(b_raddr),
      .dinb(8'h00)
  );

endmodule  //SBox_DPRom
