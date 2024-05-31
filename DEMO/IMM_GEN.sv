///////////////////////////////////////////////////////////////////////////////
// Program: IMM_GEN.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Immediate Generation Module
//
//  - Inputs:
//      I:	    	32-Bit Instruction
//      IMM_SEL:   	Selection Vector for Immediate field muxes
//
//  - Outputs:
//      IMM32:		32-Bit Immediate
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module IMM_GEN (I, IMM_SEL, IMM32);
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] I;
	input wire [8:0] IMM_SEL;
	output logic [BITS - 1 : 0] IMM32;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	wire [10:0] IMM30_20;
	wire [7:0] IMM19_12;
	wire [5:0] IMM10_5;
	wire [3:0] IMM4_1;
	wire IMM0, IMM11;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Bit 0 Determination
	assign IMM0 = IMM_SEL[1] ? (I[20]) :
				  IMM_SEL[0] ? (I[7]) : (1'b0);

	// Bits [4:1] Determination
	assign IMM4_1 = IMM_SEL[3] ? (I[24:21]) :
					IMM_SEL[2] ? (I[11:8]) : (4'b0);

	// Bits [10:5] Determination
	assign IMM10_5 = IMM_SEL[4] ? (1'b0) : (I[30:25]);

	// Bits [11] Determination
	assign IMM11 = (IMM_SEL[6]) ? (IMM_SEL[5] ? (I[31]) : (I[20])) :
								  (IMM_SEL[5] ? (I[7]) : (1'b0));
	
	// Bits [19:12] Determination
	assign IMM19_12 = IMM_SEL[7] ? (I[19:12]) : ({8{I[31]}});

	// Bits [30:20] Determination
	assign IMM30_20 = IMM_SEL[8] ? (I[30:20]) : ({11{I[31]}});
	
	// Concatenation of Immediate Vector Fields
	assign IMM32 = {I[31], IMM30_20, IMM19_12, IMM11, IMM10_5, IMM4_1, IMM0};
endmodule
`default_nettype wire