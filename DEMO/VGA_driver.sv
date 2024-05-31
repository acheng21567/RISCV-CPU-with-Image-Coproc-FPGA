// /////////////////////////////////////////////////////////////////////////////
// Program: VGA_driver.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - VGA driver module for interfacing with VGA and video memory
// 
//  - Inputs:
//     clk: 	        Global clock signal for 25MHz
//     rst_n: 	        Global active low reset
//     we: 	            Write enable signal for video memory
//     start: 	        Asserted from the host processor to start the image processing
//     wdata [11:0]: 	Pixel data to be stored to video memory
//     done: 	        Asserted by the image DMA signaling the completion of image processing
//     VGA_CLK: 	    25MHz VGA clock from PLL block
// 
//  - Outputs:
//     VGA_VS: 	        Active low vertical synch
//     VGA_HS: 	        Active low horizontal synch
//     VGA_BLANK_N: 	Assert (low) during non-active pixels
//     VGA_SYNC_N: 	    Tie it low
//     VGA_R [7:0]: 	R channel, will be tied as {rdata[11:8],4'b0}
//     VGA_G [7:0]: 	G channel, will be tied as {rdata[7:4],4'b0}
//     VGA_B [7:0]: 	B channel, will be tied as {rdata[3:0],4'b0}
// /////////////////////////////////////////////////////////////////////////////

module VGA_driver(
    input logic clk,
    input logic rst_n,
    input logic we,
    input logic start,
    input logic [11:0] wdata,
    input logic done,
    input logic VGA_CLK,

    output logic VGA_HS,
    output logic VGA_VS,
    output logic VGA_BLANK_N,
    output logic VGA_SYNC_N,
    output logic [7:0] VGA_R,
    output logic [7:0] VGA_G,
    output logic [7:0] VGA_B
);
    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    localparam Y_LIM = 9'd255;
    localparam ROW_OFFSET = 128;

    logic [18:0] raddr;
    logic [16:0] waddr, raddr_mem;
    logic [11:0] rdata, rdata_mem;
    logic [9:0] xpix;
    logic [8:0] ypix;
    logic we_out;

	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////
    VGA_timing iVGATM(.clk25MHz(VGA_CLK), .rst_n(rst_n), .VGA_BLANK_N(VGA_BLANK_N), 
                      .VGA_HS(VGA_HS),.VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), 
                      .xpix(xpix), .ypix(ypix), .addr_lead(raddr));

    VGA_DMA VGA_DMA(.clk(clk), .rst_n(rst_n), .we_in(we), .start(start), .done(done), .waddr(waddr), .we_out(we_out));

    video_mem video_mem(.clk(clk),.we(we_out),.waddr(waddr),.wdata(wdata),.raddr(raddr_mem),.rdata(rdata_mem));

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // Calculate the memory address for fitting the video memory. Video memory size is 256*512
    assign raddr_mem = raddr - ypix * ROW_OFFSET;
    assign rdata = ypix > Y_LIM ? '0 : (xpix[9] ? '0 : rdata_mem);

    // Assign VGA Color, extend 4-bit color to 8-bit
    assign VGA_R = {rdata[11:8], 4'b0};
    assign VGA_G = {rdata[7:4], 4'b0};
    assign VGA_B = {rdata[3:0], 4'b0};


endmodule