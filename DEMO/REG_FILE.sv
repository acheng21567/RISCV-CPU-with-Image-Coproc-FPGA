///////////////////////////////////////////////////////////////////////////////
// Program: REG_FILE.v
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - A General Purpose 32x32b Triple Port Register File for Dual Read,
//		Single Write
//
//  - Inputs:
//      clk:    		Global Clock
//      rst_n:    		Global Active Low Reset
//      SR1:    		Source Address 1
//      SR2:    		Source Address 2
//      RD:    			Destination Address
//      DEST_DATA:		Destination Data on Write
//      WEN:			Register Write Enable
//
//  - Outputs:
//      Data1:			Source Register 1 Data
//      Data2:			Source Register 2 Data
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module REG_FILE (clk, rst_n, SR1, SR2, RD, DEST_DATA, WEN, Data1, Data2);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] DEST_DATA;
	input wire [4 : 0] SR1, SR2, RD;
	input wire WEN, clk, rst_n;
	output wire [BITS - 1 : 0] Data1, Data2;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] REG_BANK1 [0 : 31];
	logic [BITS - 1 : 0] REG_BANK2 [0 : 31];
	logic [BITS - 1 : 0] SrcData1,  SrcData2;
	logic wen_gated;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Disable Write on RD = 0 
	assign wen_gated = WEN & (RD != 'h0);
	
	// Synchronous Register Write Port
	always_ff @(negedge clk) begin
		if (~rst_n) begin
			for (int i = 0; i < 32; i++) begin
				REG_BANK1[i] = '0;
				REG_BANK2[i] = '0;
			end
		end
		else if (wen_gated) begin
			REG_BANK1[RD] <= DEST_DATA;
			REG_BANK2[RD] <= DEST_DATA;
		end
	end
	
	// Synchronous Register Read Port 1
	always_ff @(negedge clk) begin
		if (SR1 == 'h0) begin
			SrcData1 <= 'h0;
		end
		else begin
			SrcData1 <= REG_BANK1[SR1];
		end
	end
	
	// Synchronous Register Write Port 2
	always_ff @(negedge clk) begin
		if (SR2 == 'h0) begin
			SrcData2 <= 'h0;
		end
		else begin
			SrcData2 <= REG_BANK2[SR2];
		end
	end
	
	// Register File Bypassing (All Registers Except for x0)
	assign Data1 = ((SR1 == RD) & wen_gated) ? (DEST_DATA) : (SrcData1);
	assign Data2 = ((SR2 == RD) & wen_gated) ? (DEST_DATA) : (SrcData2);

endmodule
`default_nettype wire