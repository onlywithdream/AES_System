module RAM_mem(
    input wire clk,
    input wire rstn,

    input  wire mem_valid,
    output wire mem_ready,

    input  wire [32-1:0] mem_addr,
    input  wire [32-1:0] mem_wdata,
    input  wire [ 4-1:0] mem_wstrb,
    output wire [32-1:0] mem_rdata
);

  reg mem_ready_r;

  always @(posedge clk) begin
    if (!rstn) mem_ready_r <= 1'b0;
    else if (mem_ready_r) mem_ready_r <= 1'b0;
    else if (mem_valid) mem_ready_r <= 1'b1;
    else mem_ready_r <= mem_ready_r;
  end

  RAM RAM_inst (
      .clk(clk),
      .rst(~rstn),
      .ce(mem_valid & ~mem_ready),
      .wstrb(mem_wstrb),
      .ad(mem_addr[31:2]),
      .din(mem_wdata),
      .dout(mem_rdata)
  );

  assign mem_ready = mem_ready_r;

endmodule  //RAM_mem
