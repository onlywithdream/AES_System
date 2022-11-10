module KeyExpansion (
    input wire clk,
    input wire rst,

    /*
      in_nk     nk
       00       4
       01       6
       11       8
    */
    input wire [2-1:0] in_nk,

    input wire in_start,
    input wire in_valid,
    input wire [32-1:0] in_w,

    output wire out_busy,

    output wire out_valid,
    output wire out_first_flag,
    output wire out_last_flag,
    output wire [128-1:0] out_rk
);

  //round key bufer
  wire buf_in_valid;
  wire [32-1:0] buf_in;
  reg [8*32-1:0] rk_buf;
  wire [8*32-1:0] next_rk_buf;

  //word expansion
  wire sel0;
  wire sel1;
  wire [32-1:0] rcon;

  wire new_w_valid;
  wire [32-1:0] new_w;

  assign buf_in_valid = out_busy ? new_w_valid : in_valid;

  assign buf_in = out_busy ? new_w : in_w;

  assign next_rk_buf[0+:3*32] = rk_buf[32+:3*32];
  assign next_rk_buf[3*32+:32] = in_nk[0] ? rk_buf[4*32+:32] : buf_in;
  assign next_rk_buf[4*32+:32] = rk_buf[5*32+:32];
  assign next_rk_buf[5*32+:32] = in_nk[1] ? rk_buf[6*32+:32] : buf_in;
  assign next_rk_buf[6*32+:32] = rk_buf[7*32+:32];
  assign next_rk_buf[7*32+:32] = buf_in;

  //ctrl
  KeyExpansionCtrl Ctrl_inst (
      .clk(clk),
      .rst(rst),

      .in_start(in_start),
      .in_nk(in_nk),

      .out_busy(out_busy),

      .out_valid(out_valid),
      .out_first_flag(out_first_flag),
      .out_last_flag(out_last_flag),

      .new_w_valid(new_w_valid),

      .sel0(sel0),
      .sel1(sel1),
      .rcon(rcon)
  );

  //round key buffer
  always @(posedge clk) begin
    if (buf_in_valid) rk_buf <= next_rk_buf;
  end

  //word expansion
  WordExpansion WordExpansion_inst (
      .clk(clk),

      .in_sel0(sel0),
      .in_sel1(sel1),
      .in_rcon(rcon),

      .in_old_w(rk_buf[0+:32]),
      .in_new_w(in_nk[1] ? rk_buf[7*32+:32] : (in_nk[0] ? rk_buf[5*32+:32] : rk_buf[3*32+:32])),

      .out_w(new_w)
  );

  assign out_rk = rk_buf[0+:4*32];

endmodule  //KeyExpansion
