module IterateEle (
    input wire clk,

    input wire in_load_flag,
    input wire in_rk_bypass_flag,
    input wire in_smc_1_bypass_flag,
    input wire in_smc_2_bypass_flag,

    input wire in_inv_flag,
    input wire [128-1:0] in_rk,
    input wire [128-1:0] in_s,

    output wire [128-1:0] out_s
);

  wire [128-1:0] sbox_out_s;

  wire [128-1:0] srow_out_s;

  wire [128-1:0] smc_1_out_s;
  wire [128-1:0] rkmc_1_out_s;

  wire [128-1:0] ra_out_s;
  reg  [128-1:0] ra_out_s_r;

  wire [128-1:0] smc_2_out_s;

  always @(posedge clk) begin
    ra_out_s_r  <= ra_out_s;
  end

  SBox SBox_inst (
      .clk(clk),
      .in_inv_flag(in_inv_flag),
      .in_s(smc_2_out_s),
      .out_s(sbox_out_s)
  );

  ShiftRows ShiftRows_inst (
      .clk(clk),
      .in_inv_flag(in_inv_flag),
      .in_s(sbox_out_s),
      .out_s(srow_out_s)
  );

  MixCols #(
      .MixStep(1)
  ) sMixCols_1_inst (
      .clk(clk),
      .in_bypass_flag(in_smc_1_bypass_flag),
      .in_s (srow_out_s),
      .out_s(smc_1_out_s)
  );

  MixCols #(
      .MixStep(1)
  ) rkMixCols_1_inst (
      .clk(clk),
      .in_bypass_flag(in_rk_bypass_flag),
      .in_s (in_rk),
      .out_s(rkmc_1_out_s)
  );

  RoundAdd RoundAdd_inst (
      .in_rk(rkmc_1_out_s),
      .in_s (in_load_flag ? in_s : smc_1_out_s),
      .out_s(ra_out_s)
  );

  MixCols #(
      .MixStep(2)
  ) sMixCols_2_inst (
      .clk(clk),
      .in_bypass_flag(in_smc_2_bypass_flag),
      .in_s (ra_out_s_r),
      .out_s(smc_2_out_s)
  );

  assign out_s = ra_out_s_r;

endmodule  //IterateEle
