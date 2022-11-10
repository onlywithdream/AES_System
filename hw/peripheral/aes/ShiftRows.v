module ShiftRows (
    input wire clk,

    input wire in_inv_flag,
    input wire [128-1:0] in_s,

    output wire [128-1:0] out_s
);

  reg [128-1:0] out_s_r;

  always @(posedge clk) begin
    out_s_r[0+:8] <= in_s[0+:8];
    out_s_r[32+:8] <= in_s[32+:8];
    out_s_r[64+:8] <= in_s[64+:8];
    out_s_r[96+:8] <= in_s[96+:8];

    out_s_r[0+8+:8] <= in_inv_flag ? in_s[96+8+:8] : in_s[32+8+:8];
    out_s_r[32+8+:8] <= in_inv_flag ? in_s[0+8+:8] : in_s[64+8+:8];
    out_s_r[64+8+:8] <= in_inv_flag ? in_s[32+8+:8] : in_s[96+8+:8];
    out_s_r[96+8+:8] <= in_inv_flag ? in_s[64+8+:8] : in_s[0+8+:8];

    out_s_r[0+16+:8] <= in_s[64+16+:8];
    out_s_r[32+16+:8] <= in_s[96+16+:8];
    out_s_r[64+16+:8] <= in_s[0+16+:8];
    out_s_r[96+16+:8] <= in_s[32+16+:8];

    out_s_r[0+24+:8] <= in_inv_flag ? in_s[32+24+:8] : in_s[96+24+:8];
    out_s_r[32+24+:8] <= in_inv_flag ? in_s[64+24+:8] : in_s[0+24+:8];
    out_s_r[64+24+:8] <= in_inv_flag ? in_s[96+24+:8] : in_s[32+24+:8];
    out_s_r[96+24+:8] <= in_inv_flag ? in_s[0+24+:8] : in_s[64+24+:8];
  end

  assign out_s = out_s_r;

endmodule  //ShiftRows
