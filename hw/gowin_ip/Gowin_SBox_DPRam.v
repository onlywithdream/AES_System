//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//GOWIN Version: V1.9.8.07 Education
//Part Number: GW2A-LV18PG256C8/I7
//Device: GW2A-18C
//Created Time: Wed Sep  7 19:41:54 2022

module Gowin_SBox_DPRam # (
    parameter ReadMode = 1'b0
)(douta, doutb, clka, ocea, cea, reseta, wrea, clkb, oceb, ceb, resetb, wreb, ada, dina, adb, dinb);

output [7:0] douta;
output [7:0] doutb;
input clka;
input ocea;
input cea;
input reseta;
input wrea;
input clkb;
input oceb;
input ceb;
input resetb;
input wreb;
input [8:0] ada;
input [7:0] dina;
input [8:0] adb;
input [7:0] dinb;

wire [7:0] dpb_inst_0_douta_w;
wire [7:0] dpb_inst_0_doutb_w;
wire gw_gnd;

assign gw_gnd = 1'b0;

DPB dpb_inst_0 (
    .DOA({dpb_inst_0_douta_w[7:0],douta[7:0]}),
    .DOB({dpb_inst_0_doutb_w[7:0],doutb[7:0]}),
    .CLKA(clka),
    .OCEA(ocea),
    .CEA(cea),
    .RESETA(reseta),
    .WREA(wrea),
    .CLKB(clkb),
    .OCEB(oceb),
    .CEB(ceb),
    .RESETB(resetb),
    .WREB(wreb),
    .BLKSELA({gw_gnd,gw_gnd,gw_gnd}),
    .BLKSELB({gw_gnd,gw_gnd,gw_gnd}),
    .ADA({gw_gnd,gw_gnd,ada[8:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIA({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dina[7:0]}),
    .ADB({gw_gnd,gw_gnd,adb[8:0],gw_gnd,gw_gnd,gw_gnd}),
    .DIB({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,dinb[7:0]})
);

defparam dpb_inst_0.READ_MODE0 = ReadMode;
defparam dpb_inst_0.READ_MODE1 = ReadMode;
defparam dpb_inst_0.WRITE_MODE0 = 2'b00;
defparam dpb_inst_0.WRITE_MODE1 = 2'b00;
defparam dpb_inst_0.BIT_WIDTH_0 = 8;
defparam dpb_inst_0.BIT_WIDTH_1 = 8;
defparam dpb_inst_0.BLK_SEL_0 = 3'b000;
defparam dpb_inst_0.BLK_SEL_1 = 3'b000;
defparam dpb_inst_0.RESET_MODE = "SYNC";
defparam dpb_inst_0.INIT_RAM_00 = 256'hC072A49CAFA2D4ADF04759FA7DC982CA76ABD7FE2B670130C56F6BF27B777C63;
defparam dpb_inst_0.INIT_RAM_01 = 256'h75B227EBE28012079A059618C323C7041531D871F1E5A534CCF73F362693FDB7;
defparam dpb_inst_0.INIT_RAM_02 = 256'hCF584C4A39BECB6A5BB1FC20ED00D153842FE329B3D63B52A05A6E1B1A2C8309;
defparam dpb_inst_0.INIT_RAM_03 = 256'hD2F3FF1021DAB6BCF5389D928F40A351A89F3C507F02F94585334D43FBAAEFD0;
defparam dpb_inst_0.INIT_RAM_04 = 256'hDB0B5EDE14B8EE4688902A22DC4F816073195D643D7EA7C41744975FEC130CCD;
defparam dpb_inst_0.INIT_RAM_05 = 256'h08AE7A65EAF4566CA94ED58D6D37C8E779E4959162ACD3C25C2406490A3A32E0;
defparam dpb_inst_0.INIT_RAM_06 = 256'h9E1DC186B95735610EF6034866B53E708A8BBD4B1F74DDE8C6B4A61C2E2578BA;
defparam dpb_inst_0.INIT_RAM_07 = 256'h16BB54B00F2D99416842E6BF0D89A18CDF2855CEE9871E9B948ED9691198F8E1;
defparam dpb_inst_0.INIT_RAM_08 = 256'hCBE9DEC444438E3487FF2F9B8239E37CFBD7F3819EA340BF38A53630D56A0952;
defparam dpb_inst_0.INIT_RAM_09 = 256'h25D18B6D49A25B76B224D92866A12E084EC3FA420B954CEE3D23C2A632947B54;
defparam dpb_inst_0.INIT_RAM_0A = 256'h849D8DA75746155EDAB9EDFD5048706C92B6655DCC5CA4D41698688664F6F872;
defparam dpb_inst_0.INIT_RAM_0B = 256'h6B8A130103BDAFC1020F3FCA8F1E2CD00645B3B80558E4F70AD3BC8C00ABD890;
defparam dpb_inst_0.INIT_RAM_0C = 256'h6EDF751CE837F9E28535ADE72274AC9673E6B4F0CECFF297EADC674F4111913A;
defparam dpb_inst_0.INIT_RAM_0D = 256'hF45ACD78FEC0DB9A2079D2C64B3E56FC1BBE18AA0E62B76F89C5291D711AF147;
defparam dpb_inst_0.INIT_RAM_0E = 256'hEF9CC9939F7AE52D0D4AB519A97F51605FEC8027591012B131C7078833A8DD1F;
defparam dpb_inst_0.INIT_RAM_0F = 256'h7D0C2155631469E126D677BA7E042B17619953833CBBEBC8B0F52AAE4D3BE0A0;

endmodule //Gowin_SBox_DPRam
