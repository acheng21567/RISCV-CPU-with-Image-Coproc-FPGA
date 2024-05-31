///////////////////////////////////////////////////////////////////////////////
// Program: COMPARATOR_TOP.v
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - General Purpose 32-bit Comparator for Less than / Less than Unsigned 
//
//  - Inputs:
//      A:      		Operand A Input
//      B:      		Operand B Input
//  - Outputs:
//		LT: 			Less Than Flag Result
//		LTU: 			Less Than UNSIGNED Flag Result
//		EQ: 			EQUAL Flag Result
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module COMPARATOR_TOP(A, B, LT, LTU, EQ);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] A, B;
	output logic LT, LTU, EQ;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Signed Comparison
	assign LT = $signed(A) < $signed(B);
	
	// Unsigned Comparison
	assign LTU = $unsigned(A) < $unsigned(B);
	
	// Zero Comparison
	assign EQ = (A == B);
endmodule
`default_nettype wire