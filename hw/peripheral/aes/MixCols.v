module MixCols #(
    parameter MixStep = 1
) (
    input wire clk,

    input wire in_bypass_flag,
    input wire [128-1:0] in_s,

    output wire [128-1:0] out_s
);

  genvar i;

  generate
    for (i = 0; i < 4; i = i + 1) begin : g_MixCol
      MixCol #(
          .MixStep(MixStep)
      ) MixCol_inst (
          .clk(clk),
          .in_bypass_flag(in_bypass_flag),
          .in_w(in_s[i*32+:32]),
          .out_w(out_s[i*32+:32])
      );
    end
  endgenerate

endmodule  //MixCols
