///////////////////////////////////////////////////////////////////////////////
// Program: IO_LAYER.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Top-Level I/O Layer Interfacing with CPU-TOP
//
//  - Inputs:
//      clk:    			Global Clock
//      rst_n:    			Global Active Low Reset
//      IO_ADDR:    		I/O Address
//      IO_ADDR:    		I/O Address
//      IO_WEN:    			I/O Write Enable
//      IO_RDEN:    		I/O Read Enable
//      SW:    				Switch Peripheral Input
//      KEY:    			Button Key Peripheral Input
//      COPROC_STS:    		Coprocessor Status Register
//      IO_WDATA:    		I/O Write Data Bus
//
//  - Outputs:
//		LEDR:    			LED Peripheral Output
//		COPROC_CTL:    		Coprocessor Control Register
//      IO_RDATA:    		I/O Read Data Bus
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module IO_LAYER (IO_ADDR, IO_WEN, IO_RDEN, SW, LEDR, KEY, COPROC_CTL, clk, 
		rst_n, COPROC_STS, IO_WDATA, IO_RDATA);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] IO_ADDR, IO_WDATA;
	input logic [9 : 0] SW;
	input logic [3 : 0] KEY;
	input logic [1:0] COPROC_STS;
	input logic IO_WEN, IO_RDEN, clk, rst_n;
	output logic [BITS - 1 : 0] IO_RDATA;
	output logic [9 : 0] LEDR;
	output logic [7:0] COPROC_CTL;



	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic LED_EN, SW_EN, COPROC_CTL_EN, COPROC_STS_EN, KEY_EN;

	// Memory-Mapped Register Addresses
	localparam LED_a = 32'hFFFFFFF0;
	localparam SW_a = 32'hFFFFFFF1;
	localparam KEY_a = 32'hFFFFFFF2;
	localparam COPROC_CTL_a = 32'hFFFFFFF4;
	localparam COPROC_STS_a = 32'hFFFFFFF5;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	/////////////////////
	// I/O Map Table 
	/////////////////////
	
	// LED Array
	assign LED_EN = (IO_ADDR == LED_a) & IO_WEN;
	
	// Coprocessor Register Enables
	assign COPROC_CTL_EN = (IO_ADDR == COPROC_CTL_a) & IO_WEN;
	assign COPROC_STS_EN = (IO_ADDR == COPROC_STS_a) & IO_RDEN;
	
	// Switch Array
	assign SW_EN = (IO_ADDR == SW_a) & IO_RDEN;
	
	// Key Array
	assign KEY_EN = (IO_ADDR == KEY_a) & IO_RDEN;
	
	
	/////////////////////
	// Write Peripherals
	/////////////////////
	
	// LED Register
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			LEDR <= 10'b0;
		end
		else if (LED_EN) begin
			LEDR <= IO_WDATA[9:0];
		end
	end
	
	// Coprocessor CTL Must be a Pulse for start, do NOT Register
	assign COPROC_CTL = (COPROC_CTL_EN) ? (IO_WDATA[7:0]) : (8'b0);
	
	
	/////////////////////
	// Read Peripherals
	/////////////////////
	
	// Muxing of Read Peripherals to RDATA Bus
	assign IO_RDATA = (COPROC_STS_EN) ? ({30'b0, COPROC_STS}) :
						((SW_EN) ? ({22'b0, SW}) :
						((KEY_EN) ? ({28'b0, KEY}) :
						('b0)));
endmodule