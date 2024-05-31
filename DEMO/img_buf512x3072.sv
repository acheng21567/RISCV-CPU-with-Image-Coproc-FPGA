// /////////////////////////////////////////////////////////////////////////////
// Program: img_buf512x3072.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Image buffer that stores 512x3072 pixels for image processing
// 
//  - Inputs:
//     clk: 	          Global clock signal for 25MHz
//     we: 	            Write enable for writing to specified waddr
//     waddr [8:0]: 	  9-bit write address for the image buffer 
//     raddr [8:0]: 	  9-bit Read address for the image buffer
//     wdata [3071:0]: 	3072-bit write data to be written in to the address specified by waddr
// 
//  - Outputs:
//     rdata [3071:0]: 	3072-bit read data reading out from the address specified by raddr
// /////////////////////////////////////////////////////////////////////////////

module img_buf512x3072(clk,we,waddr,raddr,rdata,wdata);

  input clk,we;
  input [8:0] waddr,raddr;
  input [3071:0] wdata;
  output reg [3071:0] rdata;

  img_buf512x640 iPART0(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[639:0]),.wdata(wdata[639:0]));
  img_buf512x640 iPART1(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[1279:640]),.wdata(wdata[1279:640]));
  img_buf512x640 iPART2(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[1919:1280]),.wdata(wdata[1919:1280]));
  img_buf512x640 iPART3(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[2559:1920]),.wdata(wdata[2559:1920]));
  img_buf512x512 iPART4(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[3071:2560]),.wdata(wdata[3071:2560]));

endmodule                        
                        