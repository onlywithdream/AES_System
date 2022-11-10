module RAM (
    input  wire clk,
    input  wire rst,

    input  wire ce,
    input  wire [4-1:0] wstrb,
    input  wire [12-1:0] ad,
    input  wire [32-1:0] din,
    output wire [32-1:0] dout
);

  Gowin_Boot_SP_8x2K_0 Gowin_Boot_SP_8x2K_0_inst (
      .dout(dout[0+:8]),
      .clk(clk),
      .oce(1'b1),
      .ce(ce),
      .reset(rst),
      .wre(wstrb[0]),
      .ad(ad),
      .din(din[0+:8])
  );
  Gowin_Boot_SP_8x2K_1 Gowin_Boot_SP_8x2K_1_inst (
      .dout(dout[8+:8]),
      .clk(clk),
      .oce(1'b1),
      .ce(ce),
      .reset(rst),
      .wre(wstrb[1]),
      .ad(ad),
      .din(din[8+:8])
  );
  Gowin_Boot_SP_8x2K_2 Gowin_Boot_SP_8x2K_2_inst (
      .dout(dout[16+:8]),
      .clk(clk),
      .oce(1'b1),
      .ce(ce),
      .reset(rst),
      .wre(wstrb[2]),
      .ad(ad),
      .din(din[16+:8])
  );
  Gowin_Boot_SP_8x2K_3 Gowin_Boot_SP_8x2K_3_inst (
      .dout(dout[24+:8]),
      .clk(clk),
      .oce(1'b1),
      .ce(ce),
      .reset(rst),
      .wre(wstrb[3]),
      .ad(ad),
      .din(din[24+:8])
  );

endmodule //RAM