module MixCol #(
    parameter MixStep = 1
) (
    input wire clk,

    input wire in_bypass_flag,
    input wire [32-1:0] in_w,

    output wire [32-1:0] out_w
);

  /*  MixStep = 1
    [02 03 01 01   [b0
     01 02 03 01    b1
     01 01 02 03 *  b2
     03 01 01 02]   b3]
    MixStep = 2
    [05 00 04 00   [b0
     00 05 00 04    b1
     04 00 05 00 *  b2
     00 04 00 05]   b3]
  */

  wire [8-1:0] in_b0;
  wire [8-1:0] in_b1;
  wire [8-1:0] in_b2;
  wire [8-1:0] in_b3;

  reg  [8-1:0] in_b0_r;
  reg  [8-1:0] in_b1_r;
  reg  [8-1:0] in_b2_r;
  reg  [8-1:0] in_b3_r;

  reg  [8-1:0] out_b0;
  reg  [8-1:0] out_b1;
  reg  [8-1:0] out_b2;
  reg  [8-1:0] out_b3;

  function [8-1:0] xtime;
    input [8-1:0] b;
    begin
      xtime = (b << 1) ^ (b[7] ? 8'h1b : 8'h00);
    end
  endfunction

  assign {in_b3, in_b2, in_b1, in_b0} = in_w;

  generate
    if (MixStep == 1) begin
      reg [8-1:0] b0_3plus_b2;
      reg [8-1:0] b1_3plus_b3;
      reg [8-1:0] b2_3plus_b0;
      reg [8-1:0] b3_3plus_b1;

      always @(posedge clk) begin
        in_b0_r <= in_b0;
        in_b1_r <= in_b1;
        in_b2_r <= in_b2;
        in_b3_r <= in_b3;

        b1_3plus_b3 <= xtime(in_b1) ^ in_b1 ^ in_b3;
        b2_3plus_b0 <= xtime(in_b2) ^ in_b2 ^ in_b0;
        b3_3plus_b1 <= xtime(in_b3) ^ in_b3 ^ in_b1;
        b0_3plus_b2 <= xtime(in_b0) ^ in_b0 ^ in_b2;

        out_b0 <= in_b0_r ^ (in_bypass_flag ? 8'h00 : b0_3plus_b2 ^ b1_3plus_b3);
        out_b1 <= in_b1_r ^ (in_bypass_flag ? 8'h00 : b1_3plus_b3 ^ b2_3plus_b0);
        out_b2 <= in_b2_r ^ (in_bypass_flag ? 8'h00 : b2_3plus_b0 ^ b3_3plus_b1);
        out_b3 <= in_b3_r ^ (in_bypass_flag ? 8'h00 : b3_3plus_b1 ^ b0_3plus_b2);
      end
    end else if (MixStep == 2) begin
      reg [8-1:0] b0_4;
      reg [8-1:0] b1_4;
      reg [8-1:0] b2_4;
      reg [8-1:0] b3_4;

      always @(posedge clk) begin
        in_b0_r <= in_b0;
        in_b1_r <= in_b1;
        in_b2_r <= in_b2;
        in_b3_r <= in_b3;

        b0_4 <= xtime(xtime(in_b0));
        b1_4 <= xtime(xtime(in_b1));
        b2_4 <= xtime(xtime(in_b2));
        b3_4 <= xtime(xtime(in_b3));

        out_b0 <= in_b0_r ^ (in_bypass_flag ? 8'h00 : b0_4 ^ b2_4);
        out_b1 <= in_b1_r ^ (in_bypass_flag ? 8'h00 : b1_4 ^ b3_4);
        out_b2 <= in_b2_r ^ (in_bypass_flag ? 8'h00 : b0_4 ^ b2_4);
        out_b3 <= in_b3_r ^ (in_bypass_flag ? 8'h00 : b1_4 ^ b3_4);
      end
    end
  endgenerate

  assign out_w = {out_b3, out_b2, out_b1, out_b0};

endmodule  //MixCol
