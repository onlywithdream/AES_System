module RAM_axi (
    input wire clk,
    input wire rstn,

    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [32-1:0] s_axi_awaddr,
    input wire [3-1:0] s_axi_awprot,

    input wire s_axi_wvalid,
    output wire s_axi_wready,
    input wire [32-1:0] s_axi_data,
    input wire [3-1:0] s_axi_wstrb,

    output wire s_axi_bvalid,
    input  wire s_axi_bready,
    output wire s_axi_bresp,

    input wire s_axi_arvalid,
    output wire s_axi_arready,
    input wire [32-1:0] s_axi_araddr,
    input wire [3-1:0] s_axi_arprot,

    output wire s_axi_rvalid,
    input  wire s_axi_rready,
    output wire s_axi_rdata,
    output wire s_axi_rresp
);
  
  reg [32-1:0] addr;


  RAM RAM_inst (
      .clk(clk),
      .rst(~rstn),
      .ce(mem_valid & ~mem_ready),
      .wstrb(mem_wstrb),
      .ad(mem_addr[31:2]),  //Align 4 bytes 
      .din(mem_wdata),
      .dout(mem_rdata)
  );



endmodule  //RAM_axi
