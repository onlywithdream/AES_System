module wrapper_MixCols (
    input wire clk,

    input wire in_bypass_flag,

    input  wire [128-1:0] in_s_1,
    output wire [128-1:0] out_s_1,

    input  wire [128-1:0] in_s_2,
    output wire [128-1:0] out_s_2
);

  reg in_bypass_flag_r;

  always @(posedge clk) begin
    in_bypass_flag_r <= in_bypass_flag;
  end

  MixCols #(
      .MixStep(1)
  ) MixCols_1_inst (
      .clk(clk),
      .in_bypass_flag(in_bypass_flag_r),
      .in_s(in_s_1),
      .out_s(out_s_1)
  );

  MixCols #(
      .MixStep(2)
  ) MixCols_2_inst (
      .clk(clk),
      .in_bypass_flag(in_bypass_flag_r),
      .in_s(in_s_2),
      .out_s(out_s_2)
  );

endmodule  //wrapper_MixCols
