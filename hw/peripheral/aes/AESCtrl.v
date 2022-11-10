module AESCtrl (
    input wire clk,
    input wire rst,

    input wire in_nk_valid,
    input wire [2-1:0] in_nk,

    input wire in_inv_valid,
    input wire in_inv,

    input wire in_key_expand,
    input wire ke_out_last_flag,

    input wire in_pct_first_flag,

    output wire [2-1:0] out_state,

    output wire out_inv,

    output wire [2-1:0] out_nk,

    output wire out_key_expand_done,

    output wire out_pct_first_flag,
    output wire out_pct_last_flag,
    output wire out_pct_valid,

    output wire rkd_inv_flag,
    output wire rkd_shift,

    output wire ie_load_flag,
    output wire ie_rk_bypass_flag,
    output wire ie_smc_1_bypass_flag,
    output wire ie_smc_2_bypass_flag
);

  localparam IDLE = 2'b00;
  localparam INV_TRANS = 2'b01;
  localparam KEY_EXPAND = 2'b10;
  localparam CIPHER = 2'b11;

  reg ke_out_last_flag_1;
  reg ke_out_last_flag_2;
  reg ke_out_last_flag_3;

  reg [2-1:0] state;
  wire idle2inv_trans_flag;
  wire idle2rk_load_flag;
  wire idle2cipher_flag;

  wire inv_trans2idle_flag;
  wire rk_load2idle_flag;
  wire cipher2idle_flag;

  reg inv;
  reg [2-1:0] nk;
  wire [4-1:0] nr;

  reg [4-1:0] hcnt;
  reg [3-1:0] lcnt;
  wire carry_flag;

  reg key_expand_done;

  reg pct_first_flag;
  reg pct_last_flag;
  reg pct_valid;

  reg rkd_inv_flag_r;
  reg rkd_shift_r;

  reg ie_load_flag_r;
  reg ie_rk_bypass_flag_r;
  reg ie_smc_1_bypass_flag_r;
  reg ie_smc_2_bypass_flag_r;

  assign idle2inv_trans_flag = in_inv_valid & (in_inv != inv);
  assign idle2rk_load_flag = in_key_expand;
  assign idle2cipher_flag = in_pct_first_flag;

  assign inv_trans2idle_flag = lcnt[1];
  assign rk_load2idle_flag = inv ? ke_out_last_flag_3 : ke_out_last_flag_2;
  assign cipher2idle_flag = hcnt == nr+1 & lcnt == 5;

  assign nr = nk[1] ? 14 : (nk[0] ? 12 : 10);

  assign carry_flag = lcnt == (hcnt == 0 ? 0 : 7);

  //signal delay
  always @(posedge clk) begin
    if (rst) begin
      ke_out_last_flag_1 <= 1'b0;
      ke_out_last_flag_2 <= 1'b0;
      ke_out_last_flag_3 <= 1'b0;
    end else begin
      ke_out_last_flag_1 <= ke_out_last_flag;
      ke_out_last_flag_2 <= ke_out_last_flag_1;
      ke_out_last_flag_3 <= ke_out_last_flag_2;
    end
  end

  //state transition
  always @(posedge clk) begin
    if (rst) state <= IDLE;
    else begin
      case (state)
        IDLE:
        if (idle2inv_trans_flag) state <= INV_TRANS;
        else if (idle2rk_load_flag) state <= KEY_EXPAND;
        else if (idle2cipher_flag) state <= CIPHER;
        INV_TRANS: if (inv_trans2idle_flag) state <= IDLE;
        KEY_EXPAND: if (rk_load2idle_flag) state <= IDLE;
        CIPHER: if (cipher2idle_flag) state <= IDLE;
      endcase
    end
  end

  //inv and nk
  always @(posedge clk) begin
    if (rst) begin
      inv <= 1'b0;
      nk  <= 2'b00;
    end else if (state == IDLE) begin
      if (in_inv_valid) inv <= in_inv;
      if (in_nk_valid) nk <= in_nk;
    end
  end

  //hcnt and lcnt
  always @(posedge clk) begin
    if (rst) begin
      hcnt <= 0;
      lcnt <= 0;
    end else begin
      case (state)
        INV_TRANS: lcnt <= lcnt + 1;
        CIPHER:
          if (carry_flag) lcnt <= 0;
          else lcnt <= lcnt + 1;
          default: lcnt <= 0;
      endcase
      case (state)
        CIPHER:  if (carry_flag) hcnt <= hcnt + 1;
        default: hcnt <= 0;
      endcase
    end
  end

  //key expand done
  always @(posedge clk) begin
    if (rst) key_expand_done <= 1'b0;
    else key_expand_done <= rk_load2idle_flag;
  end

  //pct
  always @(posedge clk) begin
    if (rst) begin
      pct_first_flag <= 1'b0;
      pct_last_flag  <= 1'b0;
      pct_valid <= 1'b0;
    end else begin
      pct_first_flag <= hcnt == nr & lcnt == 6;
      pct_last_flag  <= hcnt == nr+1 & lcnt == 5;
      if (hcnt == nr & lcnt == 6) pct_valid <= 1'b1;
      else if (pct_last_flag) pct_valid <= 1'b0;
    end
  end

  //rkd
  always @(posedge clk) begin
    if (rst) begin
      rkd_inv_flag_r <= 1'b0;
      rkd_shift_r <= 1'b0;
    end else begin
      case (state)
        IDLE: if (idle2inv_trans_flag) rkd_inv_flag_r <= !out_inv;
        default: rkd_inv_flag_r <= rkd_inv_flag_r;
      endcase
      case (state)
        IDLE: if (idle2inv_trans_flag) rkd_shift_r <= 1'b1;
        KEY_EXPAND:
          if (ke_out_last_flag & inv) rkd_shift_r <= 1'b1;
          else if (rkd_shift_r) rkd_shift_r <= 1'b0;
        CIPHER: rkd_shift_r <= lcnt == 2;
        default: rkd_shift_r <= 1'b0;
      endcase
    end
  end

  //ie
  always @(posedge clk) begin
    if (rst) begin
      ie_load_flag_r <= 1'b1;
      ie_rk_bypass_flag_r <= 1'b1;
      ie_smc_1_bypass_flag_r <= 1'b0;
      ie_smc_2_bypass_flag_r <= 1'b1;
    end else begin
      if (cipher2idle_flag) ie_load_flag_r <= 1'b1;
      else if (hcnt == 1 & lcnt[2] & lcnt[0]) ie_load_flag_r <= 1'b0;
      if (hcnt == 1 & lcnt[2]) ie_rk_bypass_flag_r <= !inv;
      else if (hcnt == nr & lcnt[2]) ie_rk_bypass_flag_r <= 1'b1;
      if (cipher2idle_flag) ie_smc_1_bypass_flag_r <= 1'b0;
      else if (hcnt == nr & lcnt[2]) ie_smc_1_bypass_flag_r <= 1'b1;
      if (cipher2idle_flag) ie_smc_2_bypass_flag_r <= 1'b1;
      else if (hcnt == 1 & lcnt == 7) ie_smc_2_bypass_flag_r <= !inv;
    end
  end

  assign out_state = state;

  assign out_inv = inv;

  assign out_nk = nk;

  assign out_key_expand_done = key_expand_done;

  assign out_pct_first_flag = pct_first_flag;
  assign out_pct_last_flag = pct_last_flag;
  assign out_pct_valid = pct_valid;

  assign rkd_inv_flag = rkd_inv_flag_r;
  assign rkd_shift = rkd_shift_r;

  assign ie_load_flag = ie_load_flag_r;
  assign ie_rk_bypass_flag = ie_rk_bypass_flag_r;
  assign ie_smc_1_bypass_flag = ie_smc_1_bypass_flag_r;
  assign ie_smc_2_bypass_flag = ie_smc_2_bypass_flag_r;

endmodule //AESCtrl
