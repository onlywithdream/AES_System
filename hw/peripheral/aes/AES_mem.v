/*
    AES_STATE      read  only  0x00000000 State
    AES_CTRL       write read  0x00000004 Inv Nk Key_extend(write) Cipher_start(write)
    AES_KEY_W      write only  0x00000008 Key_word(lower first) 
    AES_PCT_W0     write read  0x0000000C Plain_or_cipher_text_word0(lower first, up to 8 block)
    AES_PCT_W1     write read  0x00000010 Plain_or_cipher_text_word1(lower first, up to 8 block)
    AES_PCT_W2     write read  0x00000014 Plain_or_cipher_text_word2(lower first, up to 8 block)
    AES_PCT_W3     write read  0x00000018 Plain_or_cipher_text_word3(lower first, up to 8 block)
*/

module AES_mem (
    input  wire clk,
    input  wire rstn,

    input  wire mem_valid,
    output wire mem_ready,
    input  wire [32-1:0] mem_addr,
    input  wire [32-1:0] mem_wdata,
    input  wire [4-1:0] mem_wstrb,
    output wire [32-1:0] mem_rdata,

    output wire key_expand_done,
    output wire cipher_done
);

wire [7-1:0] reg_sel;

wire [32-1:0] reg0_rd;
wire [32-1:0] reg1_rd;
wire [32-1:0] reg7_rd;
wire [32-1:0] reg8_rd;
wire [32-1:0] reg9_rd;
wire [32-1:0] reg10_rd;

reg [8*32-1:0] in_pct_w0_buf;
reg [8*32-1:0] in_pct_w1_buf;
reg [8*32-1:0] in_pct_w2_buf;
reg [8*32-1:0] in_pct_w3_buf;

reg [8*32-1:0] out_pct_w0_buf;
reg [8*32-1:0] out_pct_w1_buf;
reg [8*32-1:0] out_pct_w2_buf;
reg [8*32-1:0] out_pct_w3_buf;

//cipher input
reg cipher_input;
reg [3-1:0] cipher_cnt;

//AES
reg aes_in_inv_valid;
reg aes_in_inv;

reg aes_in_nk_valid;
reg [2-1:0] aes_in_nk;

reg aes_in_key_expand;
reg aes_in_key_valid;
reg [32-1:0] aes_in_key_w;

reg aes_in_pct_first_flag;
wire [128-1:0] aes_in_pct;

wire [2-1:0] aes_out_state;

wire aes_out_inv;

wire [2-1:0] aes_out_nk;

wire aes_out_pct_first_flag;
wire aes_out_pct_last_flag;
wire aes_out_pct_valid;
wire [128-1:0] aes_out_pct;

//output port
reg mem_ready_r;
reg [32-1:0] mem_rdata_r;

genvar i;

generate
  for (i = 0; i < 7; i = i + 1) begin : g_RegSel
    assign reg_sel[i] = mem_addr[2+:3] == i;
  end
endgenerate

//AES_STATE
assign reg0_rd = aes_out_state;

//AES_CTRL
always @(posedge clk) begin
  if (!rstn) begin
    aes_in_inv_valid <= 1'b0;
    aes_in_nk_valid <= 1'b0;
    aes_in_key_expand <= 1'b0;
    aes_in_pct_first_flag <= 1'b0;
  end else if (mem_valid & (!mem_ready) & reg_sel[1]) begin
    aes_in_inv_valid <= mem_wstrb[3];
    aes_in_nk_valid <= mem_wstrb[2];
    aes_in_key_expand <= mem_wstrb[1];
    aes_in_pct_first_flag <= mem_wstrb[0];
  end else begin
    aes_in_inv_valid <= 1'b0;
    aes_in_nk_valid <= 1'b0;
    aes_in_key_expand <= 1'b0;
    aes_in_pct_first_flag <= 1'b0;
  end
end

always @(posedge clk) begin
  if (!rstn) cipher_input <= 1'b0;
  else if (cipher_cnt == 7) cipher_input <= 1'b0;
  else if (mem_valid & (!mem_ready) & reg_sel[1]) cipher_input <= mem_wstrb[0];
  if (!rstn) cipher_cnt <= 3'b0;
  else if (cipher_input) cipher_cnt <= cipher_cnt + 1;
end

always @* begin
  aes_in_inv = mem_wdata[24+:8];
  aes_in_nk = mem_wdata[16+:8];
end

assign reg1_rd[24+:8] = aes_out_inv;
assign reg1_rd[16+:8] = aes_out_nk;
assign reg1_rd[0+:16] = 16'b0;

//AES_KEY_W
always @(posedge clk) begin
  if (!rstn) aes_in_key_valid <= 1'b0;
  else if (mem_valid & (!mem_ready) & reg_sel[2]) aes_in_key_valid <= &mem_wstrb;
  else aes_in_key_valid <= 1'b0;
end

always @* begin
  aes_in_key_w = mem_wdata;
end

//write AES_PCT_W0 -- AES_PCT_W3
always @(posedge clk) begin
  if (cipher_input) begin
    in_pct_w0_buf <= {in_pct_w0_buf[0+:7*32], mem_wdata};
    in_pct_w1_buf <= {in_pct_w1_buf[0+:7*32], mem_wdata};
    in_pct_w2_buf <= {in_pct_w2_buf[0+:7*32], mem_wdata};
    in_pct_w3_buf <= {in_pct_w3_buf[0+:7*32], mem_wdata};
  end else if (mem_valid & (!mem_ready) & (&mem_wstrb)) begin
    if (reg_sel[3]) in_pct_w0_buf <= {in_pct_w0_buf[0+:7*32], mem_wdata};
    if (reg_sel[4]) in_pct_w1_buf <= {in_pct_w1_buf[0+:7*32], mem_wdata};
    if (reg_sel[5]) in_pct_w2_buf <= {in_pct_w2_buf[0+:7*32], mem_wdata};
    if (reg_sel[6]) in_pct_w3_buf <= {in_pct_w3_buf[0+:7*32], mem_wdata};
  end
end
assign aes_in_pct = {in_pct_w3_buf[8*32-1-:32], in_pct_w2_buf[8*32-1-:32], in_pct_w1_buf[8*32-1-:32], in_pct_w0_buf[8*32-1-:32]};

//read AES_PCT_W0 -- AES_PCT_W3
always @(posedge clk) begin
  if (aes_out_pct_valid) begin
    out_pct_w0_buf <= {out_pct_w0_buf[0+:7*32], aes_out_pct[0+:32]};
    out_pct_w1_buf <= {out_pct_w1_buf[0+:7*32], aes_out_pct[32+:32]};
    out_pct_w2_buf <= {out_pct_w2_buf[0+:7*32], aes_out_pct[64+:32]};
    out_pct_w3_buf <= {out_pct_w3_buf[0+:7*32], aes_out_pct[96+:32]};
  end else if (mem_valid & (!mem_ready) & (!(|mem_wstrb))) begin
    if (reg_sel[3]) out_pct_w0_buf <= {out_pct_w0_buf[0+:7*32], aes_out_pct[0+:32]};
    if (reg_sel[4]) out_pct_w1_buf <= {out_pct_w1_buf[0+:7*32], aes_out_pct[32+:32]};
    if (reg_sel[5]) out_pct_w2_buf <= {out_pct_w2_buf[0+:7*32], aes_out_pct[64+:32]};
    if (reg_sel[6]) out_pct_w3_buf <= {out_pct_w3_buf[0+:7*32], aes_out_pct[96+:32]};
  end
end

assign reg7_rd = out_pct_w0_buf[8*32-1-:32];
assign reg8_rd = out_pct_w1_buf[8*32-1-:32];
assign reg9_rd = out_pct_w2_buf[8*32-1-:32];
assign reg10_rd = out_pct_w3_buf[8*32-1-:32];

AES AES_inst (
  .clk(clk),
  .rst(~rstn),

  .in_inv_valid(aes_in_inv_valid),
  .in_inv(aes_in_inv),

  .in_nk_valid(aes_in_nk_valid),
  .in_nk(aes_in_nk),

  .in_key_expand(aes_in_key_expand),
  .in_key_valid (aes_in_key_valid),
  .in_key_w (aes_in_key_w),

  .in_pct_first_flag (aes_in_pct_first_flag),
  .in_pct (aes_in_pct),

  .out_state (aes_out_state),

  .out_inv (aes_out_inv),

  .out_nk (aes_out_nk),

  .out_key_expand_done(key_expand_done),
  
  .out_pct_first_flag(aes_out_pct_first_flag),
  .out_pct_last_flag(cipher_done),
  .out_pct_valid(aes_out_pct_valid),
  .out_pct(aes_out_pct)
);

always @(posedge clk) begin
  if (!rstn) mem_ready_r <= 1'b0;
  else mem_ready_r <= mem_valid & !mem_ready;
  if (mem_valid) begin
    case (mem_addr[2+:3])
      3'd0: mem_rdata_r <= reg0_rd;
      3'd1: mem_rdata_r <= reg1_rd;
      3'd3: mem_rdata_r <= reg7_rd;
      3'd4: mem_rdata_r <= reg8_rd;
      3'd5: mem_rdata_r <= reg9_rd;
      3'd6: mem_rdata_r <= reg10_rd;
      default: mem_rdata_r <= 32'b0;
    endcase
  end
end

assign mem_ready = mem_ready_r;
assign mem_rdata = mem_rdata_r;

endmodule //AES_mem
