module RKeyDistributor (
    input wire clk,

    input wire [2-1:0] in_nk,

    input wire in_valid,
    input wire [128-1:0] in_rk,

    input wire in_inv_flag,    
    input wire in_shift,

    output wire [15*128-1:0] out_rk
);

  reg [15*128-1:0] rk;
  wire [128-1:0] rk_in;
  wire [15*128-1:0] next_rk;
  wire [15*128-1:0] next_inv_rk;

  assign rk_in = in_valid ? in_rk : rk[0+:128];

  assign next_rk = {rk_in, 
                    rk[14*128+:128], 
                    in_nk[1] ? rk[13*128+:128] : rk_in, 
                    rk[12*128+:128], 
                    in_nk[0] ? rk[11*128+:128] : rk_in, 
                    rk[128+:10*128]};

  assign next_inv_rk = {rk[0+:14*128], 
                        in_nk[1] ? rk[14*128+:128] : 
                        (in_nk[0] ? rk[12*128+:128] : rk[10*128+:128])};

  always @(posedge clk) begin
    if (in_valid | in_shift) rk <= (in_inv_flag & !in_valid) ? next_inv_rk : next_rk;
  end

  assign out_rk = rk;

endmodule  //RKeyDistributor
