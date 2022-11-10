module sync_e2u (
    input  wire uclk,
    input  wire erstn,
    input  wire pll_lock,
    output wire urstn
);

  wire rstn;
  reg [1:0] urstn_r;

  assign rstn = erstn & pll_lock;

  always @(posedge uclk or negedge rstn) begin
    if (~rstn) urstn_r <= 2'b00;
    else urstn_r <= {urstn_r[0], 1'b1};
  end

  assign urstn = urstn_r[1];

endmodule
