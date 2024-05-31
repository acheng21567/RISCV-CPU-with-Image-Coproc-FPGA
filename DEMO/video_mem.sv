// /////////////////////////////////////////////////////////////////////////////
// Program: video_mem.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - A 256 * 256 * 2 (two images side by side) video memory module, with each pixel being 12 bits
// 
//  - Inputs:
//     clk: 	        Global clock signal for 25MHz
//     we: 	          Write enable
//     waddr [16:0]: 	17-bit write address
//     wdata [11:0]: 	12-bit pixel to be written into video memory
//     raddr [16:0]: 	17-bit read address
// 
//  - Outputs:
//     rdata [11:0]: 	12-bit to be read from video memory
// /////////////////////////////////////////////////////////////////////////////

module video_mem(
    input logic clk,
    input logic we,
    input logic [16:0] waddr,
    input logic [11:0] wdata,
    input logic [16:0] raddr,
    output logic [11:0] rdata
);
  ////////////////////////////////////////////////////////////
  ///////// Local Param & Internal Signal Declaration ////////
  ////////////////////////////////////////////////////////////
  // we will be storing two images, with each pixel being 4 bits in three channels
  // 256 * 256 * 2 = 131072 pixels
  reg [11:0]mem[0:131071];
  
	////////////////////////////////////////////////////////////
  ///////////////////// Module Operation /////////////////////
  ////////////////////////////////////////////////////////////
  always @(posedge clk) begin
    if (we) begin
	    mem[waddr] <= wdata;
    end
	  rdata <= mem[raddr];
  end

endmodule