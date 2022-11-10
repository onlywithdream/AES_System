module RoundAdd (
    input  wire [128-1:0] in_rk,
    input  wire [128-1:0] in_s,

    output wire [128-1:0] out_s
);

  assign out_s = in_rk ^ in_s;

endmodule  //RoundAdd
