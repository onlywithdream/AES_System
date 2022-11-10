module AES (
    input wire clk,
    input wire rst,

    input wire in_inv_valid,
    input wire in_inv,

    input wire in_nk_valid,
    input wire [2-1:0] in_nk,

    input wire in_key_expand,
    input wire in_key_valid,
    input wire [32-1:0] in_key_w,

    input wire in_pct_first_flag,
    input wire [128-1:0] in_pct,

    output wire [2-1:0] out_state,

    output wire out_inv,

    output wire [2-1:0] out_nk,

    output wire out_key_expand_done,

    output wire out_pct_first_flag,
    output wire out_pct_last_flag,
    output wire out_pct_valid,
    output wire [128-1:0] out_pct
);

  wire ke_out_valid;
  wire ke_out_first_flag;
  wire ke_out_last_flag;
  wire [128-1:0] ke_out_rk;

  wire rkd_inv_flag;
  wire rkd_shift;
  wire [15*128-1:0] rkd_rk;

  wire ie_load_flag;
  wire ie_rk_bypass_flag;
  wire ie_smc_1_bypass_flag;
  wire ie_smc_2_bypass_flag;

  AESCtrl AESCtrl_inst (
      .clk(clk),
      .rst(rst),

      .in_nk_valid(in_nk_valid),
      .in_nk(in_nk),

      .in_inv_valid(in_inv_valid),
      .in_inv(in_inv),

      .in_key_expand(in_key_expand),
      .ke_out_last_flag(ke_out_last_flag),

      .in_pct_first_flag(in_pct_first_flag),

      .out_state(out_state),

      .out_inv(out_inv),

      .out_nk(out_nk),

      .out_key_expand_done(out_key_expand_done),

      .out_pct_first_flag(out_pct_first_flag),
      .out_pct_last_flag (out_pct_last_flag),
      .out_pct_valid(out_pct_valid),

      .rkd_inv_flag(rkd_inv_flag),
      .rkd_shift(rkd_shift),

      .ie_load_flag(ie_load_flag),
      .ie_rk_bypass_flag(ie_rk_bypass_flag),
      .ie_smc_1_bypass_flag(ie_smc_1_bypass_flag),
      .ie_smc_2_bypass_flag(ie_smc_2_bypass_flag)
  );

  KeyExpansion KeyExpansion_inst (
      .clk(clk),
      .rst(rst),

      .in_nk(out_nk),
      .in_start(in_key_expand),
      .in_valid(in_key_valid),
      .in_w(in_key_w),

      .out_busy(),

      .out_valid(ke_out_valid),
      .out_first_flag(ke_out_first_flag),
      .out_last_flag(ke_out_last_flag),
      .out_rk(ke_out_rk)
  );

  RKeyDistributor RKeyDistributor_inst (
      .clk(clk),

      .in_nk(out_nk),

      .in_valid(ke_out_valid),
      .in_rk(ke_out_rk),

      .in_inv_flag(rkd_inv_flag),
      .in_shift(rkd_shift),

      .out_rk(rkd_rk)
  );

  IterateEle IterateEle_inst (
      .clk(clk),

      .in_load_flag(ie_load_flag),
      .in_rk_bypass_flag(ie_rk_bypass_flag),
      .in_smc_1_bypass_flag(ie_smc_1_bypass_flag),
      .in_smc_2_bypass_flag(ie_smc_2_bypass_flag),

      .in_inv_flag(out_inv),
      .in_rk(rkd_rk[0+:128]),
      .in_s(in_pct),

      .out_s(out_pct)
  );

endmodule  //AES
