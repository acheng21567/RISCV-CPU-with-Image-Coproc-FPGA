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
module Microprocessor (clk, rst_n, RX, SW, LEDR, KEY, HLT);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [9:0] SW;
	input logic [3:0] KEY;
	input logic clk, rst_n, RX;
	output logic [9:0] LEDR;
	output logic HLT;



	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] IO_WDATA, IO_RDATA, IO_ADDR;
	logic [7:0] COPROC_CTL;
	logic [1:0] COPROC_STS;
	logic IO_WEN, IO_RDEN, LED_EN, SW_EN, enable_write_databus;

	logic [IB_DW - 1 : 0] wdata_data;
    logic [ADDRW : 0] wdata_addr;
    logic [2:0] dst;
    logic bootloading;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Reset Synch Instantiation
	
	
	// I/O Layer Instantiation
	IO_LAYER IO(.IO_ADDR(IO_ADDR), .IO_WEN(IO_WEN), .IO_RDEN(IO_RDEN), .SW(SW),
		.LEDR(LEDR), .KEY(KEY), .COPROC_CTL(COPROC_CTL), .IO_RDATA(IO_RDATA),
		.COPROC_STS(COPROC_STS), .clk(clk), .rst_n(rst_n), .IO_WDATA(IO_WDATA));
	
	// RISC-V CPU Instantiation
	CPU CPU(.clk(clk), .rst_n(rst_n & ~bootloading), .HLT(HLT), .IO_WDATA(IO_WDATA),
		.IO_RDATA(IO_RDATA), .IO_ADDR(IO_ADDR), .IO_WEN(IO_WEN),
		.IO_RDEN(IO_RDEN), .wdata_data(wdata_data[IB_DW - 1 : IB_DW - BITS]), .wdata_addr(wdata_addr), 
		.bootloading(bootloading), .dst(dst));
	
	// Coprocessor Instantiation
	coproc iCOPROC(.clk(clk), .rst_n(rst_n), .VGA_CLK(clk), .start(COPROC_CTL[7]), .gray(COPROC_CTL[6]),
	.img_idx(COPROC_CTL[5]), .func(COPROC_CTL[2:0]), .rdy(COPROC_STS[0]), .VGA_B(), .VGA_G(), .VGA_R(),
	.VGA_BLANK_N(), .VGA_SYNC_N(), .VGA_HS(), .VGA_VS(), .done(COPROC_STS[1]));
	
	// Bootloader Instantiation
	UART_boot Boot(.clk(clk), .rst_n(rst_n), .RX(RX), .wdata_data(wdata_data), .wdata_addr(wdata_addr), 
				.dst(dst), .bootloading(bootloading));

endmodule
`default_nettype wire