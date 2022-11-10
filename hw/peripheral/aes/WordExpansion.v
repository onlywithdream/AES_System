module WordExpansion (
    input wire clk,

    input wire in_sel0,
    input wire in_sel1,

    input wire [32-1:0] in_rcon,
    input wire [32-1:0] in_old_w,
    input wire [32-1:0] in_new_w,

    output wire [32-1:0] out_w
);
  wire [32-1:0] subw;
  wire [32-1:0] r_subw;

  reg  [32-1:0] sel0_result;

  genvar i;

  generate
    for (i = 0; i < 2; i = i + 1) begin : g_SubWord
      SBox_DPRom #(
          .ReadMode(1'b1)
      ) SBox_DPRom_inst (
          .clk(clk),

          .a_raddr({1'b0, in_new_w[2*i*8+:8]}),
          .a_rdata(subw[2*i*8+:8]),

          .b_raddr({1'b0, in_new_w[(2*i+1)*8+:8]}),
          .b_rdata(subw[(2*i+1)*8+:8])
      );
    end
  endgenerate

  assign r_subw = {subw[0+:8], subw[8+:24]};

  always @(posedge clk) begin
    sel0_result <= in_sel0 ? subw : (in_rcon ^ r_subw);
  end

  assign out_w = (in_sel1 ? sel0_result : in_new_w) ^ in_old_w;

endmodule  //WordExpansion
