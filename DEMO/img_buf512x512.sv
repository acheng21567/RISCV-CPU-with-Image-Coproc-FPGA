// /////////////////////////////////////////////////////////////////////////////
// Program: img_buf512x512.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Image buffer that stores 512x512 pixels for image processing
// 
//  - Inputs:
//     clk: 	Global clock signal for 25MHz
//     we: 	Write enable for writing to specified waddr
//     waddr [8:0]: 	9-bit write address for the image buffer 
//     raddr [8:0]: 	9-bit Read address for the image buffer
//     wdata [511:0]: 	512-bit write data to be written in to the address specified by waddr
// 
//  - Outputs:
//     rdata [511:0]: 	512-bit read data reading out from the address specified by raddr
// /////////////////////////////////////////////////////////////////////////////

module img_buf512x512 (clk,we,waddr,raddr,rdata,wdata);
  
  input clk,we;
  input [8:0] waddr,raddr;
  input [511:0] wdata;
  output reg [511:0] rdata;
  
reg [511:0]mem10k[0:511];
  
  always @(posedge clk) begin
    if (we)
      mem10k[waddr] <= wdata;
    rdata <= mem10k[raddr];
  end
 
endmodule
  