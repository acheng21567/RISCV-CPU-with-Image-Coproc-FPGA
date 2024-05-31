///////////////////////////////////////////////////////////////////////////////
// Program: Microprocessor.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Microprocessor Containing RISC-V CPU Core & Peripherals
//
//  - Inputs:
//      clk:    		Global Clock
//      rst_n:    		Global Active Low Reset
//      RX:    			UART RX Line for Bootloading
//      SW:    			On-Board 10-Bit Switch Array
//      KEY:    		On-Board 4-Bit Button Key Array
//
//  - Outputs:
//      LEDR:    		On-Board 10-Bit LED Array
//      HLT:    		CPU Global Halt
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module Microprocessor(
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	
	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,
	
	//////////// UART //////////
	input 		     			RX,

	//////////// LED //////////
	output 		     [9:0]		LEDR,
	
	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] IO_WDATA, IO_RDATA, IO_ADDR;
	logic [7:0] COPROC_CTL;
	logic [1:0] COPROC_STS;
	logic IO_WEN, IO_RDEN, LED_EN, SW_EN, enable_write_databus;

	logic [IB_DW - 1 : 0] wdata_data;
    logic [ADDRW : 0] wdata_addr;
    logic [2:0] key_out;
    logic [2:0] dst;
    logic bootloading;
	
	logic clk, rst_n;
	logic HLT;
	logic pll_locked;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// KEY Button Debouncer
	Debouncer DEBOUNCE [2:0](.clk(clk), .rst_n(rst_n), .button_in(~KEY[2:0]), .button_pulse(key_out));
	
	// PLL Instantiation
	PLL iPLL(.refclk(CLOCK_50), .rst(~KEY[3]), .outclk_0(clk), .outclk_1(VGA_CLK),
           .locked(pll_locked));
		   
	// Reset Synch Instantiation
	rst_synch iRST(.clk(clk), .RST_n(KEY[3]), .pll_locked(pll_locked), .rst_n(rst_n));
	
	// I/O Layer Instantiation
	IO_LAYER IO(.IO_ADDR(IO_ADDR), .IO_WEN(IO_WEN), .IO_RDEN(IO_RDEN), .SW(SW),
		.LEDR(LEDR), .KEY(key_out), .COPROC_CTL(COPROC_CTL), .IO_RDATA(IO_RDATA),
		.COPROC_STS(COPROC_STS), .clk(clk), .rst_n(rst_n), .IO_WDATA(IO_WDATA));
	
	// RISC-V CPU Instantiation
	CPU CPU(.clk(clk), .rst_n(rst_n & ~bootloading), .HLT(HLT), .IO_WDATA(IO_WDATA),
		.IO_RDATA(IO_RDATA), .IO_ADDR(IO_ADDR), .IO_WEN(IO_WEN),
		.IO_RDEN(IO_RDEN), .wdata_data(wdata_data[IB_DW - 1 : IB_DW - BITS]), .wdata_addr(wdata_addr), 
		.bootloading(bootloading), .dst(dst));
	
	// Coprocessor Instantiation
	coproc iCOPROC(.clk(clk), .rst_n(rst_n & ~bootloading), .VGA_CLK(VGA_CLK), .start(COPROC_CTL[7]),
		.gray(COPROC_CTL[6]), .img_idx(COPROC_CTL[5]), .func(COPROC_CTL[2:0]), .rdy(COPROC_STS[0]), .VGA_B(VGA_B),
		.VGA_G(VGA_G), .VGA_R(VGA_R), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_HS(VGA_HS), 
		.VGA_VS(VGA_VS), .done(COPROC_STS[1]), .we_boot(dst[0]), .wdata_boot(wdata_data), .waddr_boot(wdata_addr[8:0]), 
		.bootloading(bootloading));
	
	// Bootloader Instantiation
	UART_boot Boot(.clk(clk), .rst_n(rst_n), .RX(RX), .wdata_data(wdata_data),
		.wdata_addr(wdata_addr), .dst(dst), .bootloading(bootloading));


endmodule
`default_nettype wire