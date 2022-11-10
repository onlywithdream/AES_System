module Ether_Rx # (
    parameter IncFrameStart = 1
)(
    //RMII interface with the ethernet PHY chip
    input  wire rx_clk,//Common reference for tx and rx
    input  wire rx_en,
    input  wire [2-1:0] rx_di,//Lower first within byte, higher first within bytes

    input  wire rst,

    output wire sync_flag,//Assert when meet preamble (0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55)
    output wire start_flag,//Assert when meet start frame delimiter (SFD, 0xd5)
    output wire des_mac_valid,
    output wire [6*8-1:0] des_mac,
    output wire src_mac_valid,
    output wire [6*8-1:0] src_mac,
    output wire len_type_valid,
    output wire [2*8-1:0] len_type,
    output wire data_valid,
    output wire [32-1:0] data,
    output wire done_flag//Assert when transmission of a package is done
);

localparam WAIT_PREABLE  = 3'd0;
localparam WAIT_SFD      = 3'd1;
localparam RECV_DES_MAC  = 3'd2;
localparam RECV_SRC_MAC  = 3'd3;
localparam RECV_LEN_TYPE = 3'd4;
localparam RECV_DATA     = 3'd5;
localparam RECV_FCS      = 3'd6;

reg [3-1:0] state;

wire byte_valid;
wire [8-1:0] rx_byte;
reg [2-1:0] bits_cnt;

wire wp_bytes_cnt_max_flag;
wire ws_bytes_cnt_max_flag;
wire rdm_bytes_cnt_max_flag;
wire rsm_bytes_cnt_max_flag;
wire rlt_bytes_cnt_max_flag;
wire rd_bytes_cnt_max_flag;
wire rf_bytes_cnt_max_flag;
reg bytes_cnt_max_flag;

reg [11-1:0] bytes_cnt;

reg [11-1:0] data_bytes_n;

reg sync_flag_r;
reg start_flag_r;

reg des_mac_valid_r;

reg src_mac_valid_r;

reg len_type_valid_r;

reg data_valid_r;
reg [48-1:0] data_r;
wire [48-1:0] next_data;

reg done_flag_r;

assign byte_valid = rx_en & bits_cnt == 2'd3;
assign rx_byte = next_data[0+:8];

assign wp_bytes_cnt_max_flag  = bytes_cnt[0+:3] == 3'd6;
assign ws_bytes_cnt_max_flag  = 1'b1;
assign rdm_bytes_cnt_max_flag = bytes_cnt[0+:3] == 3'd5;
assign rsm_bytes_cnt_max_flag = bytes_cnt[0+:3] == 3'd5;
assign rlt_bytes_cnt_max_flag = bytes_cnt[0]    == 1'd1;
assign rd_bytes_cnt_max_flag  = bytes_cnt       == data_bytes_n - 1;
assign rf_bytes_cnt_max_flag  = bytes_cnt[0+:2] == 2'd3;

assign next_data = {data_r[32+:2], data_r[42+:6], 
                    data_r[24+:2], data_r[34+:6], 
                    data_r[16+:2], data_r[26+:6], 
                    data_r[8+:2], data_r[18+:6], 
                    data_r[0+:2], data_r[10+:6], 
                    rx_di, data_r[2+:6]};

always @(posedge rx_clk) begin
    if (rst) state <= WAIT_PREABLE;
    else if (byte_valid & bytes_cnt_max_flag) begin
        if (state == RECV_FCS) state <= WAIT_PREABLE;
        else if (state == WAIT_SFD) state <= rx_byte == 8'hd5 ? state + 1 : WAIT_PREABLE;
        else state <= state + 1;
    end
end

always @* begin
    case (state)
        WAIT_PREABLE : bytes_cnt_max_flag = wp_bytes_cnt_max_flag;
        WAIT_SFD     : bytes_cnt_max_flag = ws_bytes_cnt_max_flag;
        RECV_DES_MAC : bytes_cnt_max_flag = rdm_bytes_cnt_max_flag;
        RECV_SRC_MAC : bytes_cnt_max_flag = rsm_bytes_cnt_max_flag;
        RECV_LEN_TYPE: bytes_cnt_max_flag = rlt_bytes_cnt_max_flag;
        RECV_DATA    : bytes_cnt_max_flag = rd_bytes_cnt_max_flag;
        RECV_FCS     : bytes_cnt_max_flag = rf_bytes_cnt_max_flag;
        default      : bytes_cnt_max_flag = 1'b1;
    endcase
end

always @(posedge rx_clk) begin
    if (rst) bits_cnt <= 2'b0;
    else if (rx_en) bits_cnt <= bits_cnt + 1;
    if (rst) bytes_cnt <= 0;
    else if (byte_valid) begin
        if (state == WAIT_PREABLE) begin
            if (rx_byte == 8'h55) bytes_cnt <= bytes_cnt_max_flag ? 0 : bytes_cnt + 1;
            else bytes_cnt <= 0;
        end
        else bytes_cnt <= bytes_cnt_max_flag ? 0 : bytes_cnt + 1;
    end
end

always @(posedge rx_clk) begin
    if (rst) data_bytes_n <= 0;
    else if (byte_valid & state == RECV_LEN_TYPE & rlt_bytes_cnt_max_flag) data_bytes_n <= next_data[0+:16];
end

always @(posedge rx_clk) begin
    if (rst | !byte_valid) begin
        sync_flag_r <= 1'b0;
        start_flag_r <= 1'b0;
        des_mac_valid_r <= 1'b0;
        src_mac_valid_r <= 1'b0;
        len_type_valid_r <= 1'b0;
        data_valid_r <= 1'b0;
        done_flag_r <= 1'b0;
    end else begin
        sync_flag_r <= state == WAIT_PREABLE & wp_bytes_cnt_max_flag;
        start_flag_r <= state == WAIT_SFD & ws_bytes_cnt_max_flag & rx_byte == 8'hd5;
        des_mac_valid_r <= state == RECV_DES_MAC & rdm_bytes_cnt_max_flag;
        src_mac_valid_r <= state == RECV_SRC_MAC & rsm_bytes_cnt_max_flag;
        len_type_valid_r <= state == RECV_LEN_TYPE & rlt_bytes_cnt_max_flag;
        data_valid_r <= (IncFrameStart & ((state == RECV_LEN_TYPE & rlt_bytes_cnt_max_flag) | (state == RECV_SRC_MAC & rsm_bytes_cnt_max_flag))) | 
                        (state == RECV_DATA & (bytes_cnt[0+:2] == 2'd3 | rd_bytes_cnt_max_flag));
        done_flag_r <= state == RECV_FCS & rf_bytes_cnt_max_flag;
    end
end

always @(posedge rx_clk) begin
    if (rx_en) data_r <= next_data;
end

//Output ports
assign sync_flag = sync_flag_r;
assign start_flag = start_flag_r;
assign des_mac_valid = des_mac_valid_r;
assign des_mac = data_r[0+:6*8];
assign src_mac_valid = src_mac_valid_r;
assign src_mac = data_r[0+:6*8];
assign len_type_valid = len_type_valid_r;
assign len_type = data_r[0+:2*8];
assign data_valid = data_valid_r;
assign data = data_r[0+:32];
assign done_flag = done_flag_r;

endmodule //Ether_Rx