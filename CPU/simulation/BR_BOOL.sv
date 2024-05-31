///////////////////////////////////////////////////////////////////////////////
// Program: BR_BOOL.v
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Condition Comparison Logic for Branch Detection
//
//  - Inputs:
//      SR1:      		Operand A Input
//      SR2:      		Operand B Input
//		BRANCH_CCC:		Condition Codes of Current Instruction
//
//  - Outputs:
//		BRANCH: 		Flag signifying branch should be taken
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module BR_BOOL(SR1, SR2, BRANCH_CCC, BRANCH);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] SR1, SR2;
	input branch_t BRANCH_CCC;
	output wire BRANCH;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	wire LT, LTU, EQ, BEQ_en, BNE_en, BLT_en, BGE_en, BLTU_en, BGEU_en;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Comparator Instantiation for Operand Comparison
	COMPARATOR_TOP comp(.A(SR1), .B(SR2), .LT(LT), .LTU(LTU), .EQ(EQ));
	
	// Condition Code Comparison with Comparator Flags
	assign BEQ_en = EQ & (BRANCH_CCC == BEQ);
	assign BNE_en = ~EQ & (BRANCH_CCC == BNE);
	assign BLT_en = LT & (BRANCH_CCC == BLT);
	assign BGE_en = ~LT & (BRANCH_CCC == BGE);
	assign BLTU_en = LTU & (BRANCH_CCC == BLTU);
	assign BGEU_en = ~LTU & (BRANCH_CCC == BGEU);
	
	// Signify BRANCH Flag if any condition comparisons are met
	assign BRANCH = BEQ_en | BNE_en | BLT_en | BGE_en | BLTU_en | BGEU_en;
endmodule
`default_nettype wire