module video_mem(
    input logic clk,
    input logic we,
    input logic [16:0] waddr,
    input logic [11:0] wdata,
    input logic [16:0] raddr,
    output logic [11:0] rdata
);

  // we will be storing two images, with each pixel being 4 bits in three channels
  // 256 * 256 * 2 = 131072 pixels
  reg [11:0]mem[0:131071];
  
  always @(posedge clk) begin
    if (we)
	  mem[waddr] <= wdata;
	rdata <= mem[raddr];
  end

endmodule