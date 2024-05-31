///////////////////////////////////////////////////////////////////////////////
// Program: DATA_BANK.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - General Purpose Parameterizable Single Port RAM Block for Data Memory
//		for Single Cycle RAM Access
//	- NOTE: INTENDED FOR ONE BYTE WORDS. DATA MEMORY WILL CONTAIN 4 BANKS
//
//  - Inputs:
//      clk:    			Global Clock 
//      addr:    			Memory Access Address
//		rden:				Memory Read Enable
//		wen:				Memory Write Enable
//		Data_In:			Memory Write Data In
//
//  - Outputs:
//      Data_Out:			Output Data Accessed from Memory
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module DATA_BANK #(BITS = 8, ADDRW = 13)
		(clk, addr, rden, wen, Data_In, Data_Out);
	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] Data_In;
	input logic [ADDRW - 1 : 0] addr;
	input logic clk, rden, wen;
	output logic [BITS - 1 : 0] Data_Out;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	
	// Parameterizable RAM Block
	reg [BITS - 1 : 0] RAM [0 : (2**ADDRW) - 1];
	

	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
	
	// Synchronous Write
	always_ff @(negedge clk) begin
		if (wen) begin
			RAM[addr] <= Data_In;
		end
	end
	
	// Synchronous Read
	always_ff @(negedge clk) begin
		if (rden) begin
			Data_Out <= RAM[addr];
		end
		else begin
			Data_Out <= 'h0;
		end
	end
endmodule
`default_nettype wire