module SBox (
    input  wire clk,

    input  wire in_inv_flag,
    input  wire [128-1:0] in_s,

    output wire [128-1:0] out_s
);

  genvar i;

  generate
    for (i = 0; i < 8; i = i + 1) begin : g_SBoxDPRom
      SBox_DPRom #(
          .ReadMode(1'b1)
      )SBox_DPRom_inst(
          .clk(clk),

          .a_raddr({in_inv_flag, in_s[8*2*i+:8]}),
          .a_rdata(out_s[8*2*i+:8]),

          .b_raddr({in_inv_flag, in_s[8*(2*i+1)+:8]}),
          .b_rdata(out_s[8*(2*i+1)+:8])
      );
    end
  endgenerate

endmodule  //SBox
