module KeyExpansionCtrl (
    input  wire clk,
    input  wire rst,

    input  wire [2-1:0] in_nk,

    input  wire in_start,

    output wire out_busy,
    
    output wire out_valid,
    output wire out_first_flag,
    output wire out_last_flag,

    output wire new_w_valid,

    output wire sel0,
    output wire sel1,
    output wire [32-1:0] rcon
);

  localparam IDLE = 1'b0;
  localparam BUSY = 1'b1;

  reg state;

  wire hcnt_incr_flag;
  //index of word
  reg [4-1:0] hcnt;
  reg [3-1:0] lcnt;
  //step for word expansion
  reg [2-1:0] vcnt;
  //num of words going to buffer
  reg [2-1:0] wcnt;

  wire last_w_flag;

  reg expansion_done_flag_0;
  reg expansion_done_flag_1;

  wire out_valid_flag;
  wire out_last_flag_flag;

  wire new_w_valid_flag;

  reg out_valid_r;
  reg out_first_flag_r;
  reg out_last_flag_r;

  reg new_w_valid_r;

  wire rb_updata_flag;
  reg [8-1:0] rb;

  assign hcnt_incr_flag = in_nk[1] ? &lcnt : ((in_nk[0] ? lcnt[2] : lcnt[1]) & lcnt[0]);

  /*Nk hcnt lcnt
    4   9    3
    6   7    3
    8   6    3  */
  assign last_w_flag = lcnt[0+:2] == 3 & //rise when this is last word for this nk
                       (in_nk[1] ? &hcnt[1+:2] : (in_nk[0] ? &hcnt[0+:3] : hcnt[3] & hcnt[0]));

  assign out_valid_flag = (expansion_done_flag_0 ? 1'b1 : vcnt == 3) & wcnt == 3;//valid when every 4 word is pushed out of ports 
  assign out_last_flag_flag = wcnt == 3 & (in_nk[1] ? expansion_done_flag_1 : expansion_done_flag_0);//done when expansion is done and push all word out of ports
  
  assign new_w_valid_flag = vcnt == 2 | expansion_done_flag_0;//push when a word is expansed or expansion is done

  assign rb_updata_flag = hcnt_incr_flag;

  //state transition
  always @(posedge clk) begin
    if (rst) state <= IDLE;
    else begin
      case (state)
        IDLE: if (in_start) state <= BUSY;
        BUSY: if (out_last_flag) state <= IDLE;
      endcase
    end
  end

  //cnt
  always @(posedge clk) begin
    case (state)
      IDLE: begin
        hcnt <= 0;
        lcnt <= 0;
        wcnt <= 0;
        vcnt <= 0;
      end
      BUSY: begin
        if (new_w_valid) begin
          if (hcnt_incr_flag) begin
            hcnt <= hcnt + 1;
            lcnt <= 0;
          end
          else lcnt <= lcnt + 1;
          wcnt <= wcnt + 1;
        end
        vcnt <= vcnt + 1;
      end
    endcase
  end
  
  always @(posedge clk) begin
    case (state)
      IDLE: expansion_done_flag_0 <= 1'b0;
      BUSY: if (vcnt == 2 & last_w_flag) expansion_done_flag_0 <= 1'b1;
    endcase
    expansion_done_flag_1 <= expansion_done_flag_0;
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        out_valid_r <= in_start;
        out_first_flag_r <= in_start;
        out_last_flag_r <= 1'b0;
        new_w_valid_r <= 1'b0;
      end
      BUSY: begin
        out_valid_r <= out_valid_flag;
        out_first_flag_r <= 1'b0;
        out_last_flag_r <= out_last_flag_flag;
        new_w_valid_r <= new_w_valid_flag;
      end
    endcase
  end

  //round constant
  always @(posedge clk) begin
    case (state)
      IDLE: rb <= 8'h01;
      BUSY: begin
        if (new_w_valid) begin
          if (rb_updata_flag) rb <= (rb[7] ? 8'h1b : 8'h00) ^ (rb << 1);
        end
      end
    endcase
  end

  assign out_busy = state;

  assign out_valid = out_valid_r;
  assign out_first_flag = out_first_flag_r;
  assign out_last_flag = out_last_flag_r;

  assign new_w_valid = new_w_valid_r;

  assign sel0 = lcnt[2];
  assign sel1 = lcnt[0+:2] == 0 & (!(in_nk == 1 & lcnt[2]));
  assign rcon = {24'h000000, rb};

endmodule //KeyExpansionCtrl
