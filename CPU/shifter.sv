///////////////////////////////////////////////////////////////////////////////
// Program: shifter.v
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - A General Purpose Barrel Shifter (32-bit)
//
//  - Inputs:
//      Shifter_In:    	Input Shifter Operand
//      SHAMT:      	Shift Amount [5:0]
//      SHIFT_OP:		Shift Operation
// 			- SHIFT_OP == 00 -> SLL
// 			- SHIFT_OP == 01 -> SRL
// 			- SHIFT_OP == 11 -> SRA
//
//  - Outputs:
//      Shifter_Out:	Output Shifted Result
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module shifter (Shifter_In, SHAMT, SHIFT_OP, Shifter_Out);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] Shifter_In;
	input wire [$clog2(BITS) - 1 : 0] SHAMT;
	input shift_t SHIFT_OP;
	output wire [BITS - 1 : 0] Shifter_Out;



	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	wire [BITS - 1 : 0] imSF_0, imSF_1, imSF_2, imSF_3;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	assign imSF_0 = SHIFT_OP[0] ? 
					(SHAMT[0] ? {SHIFT_OP[1] ? {1{Shifter_In[BITS - 1]}} : 1'b0, Shifter_In[BITS - 1 : 1]} : Shifter_In) : 
					(SHAMT[0] ? {Shifter_In[BITS - 2 : 0], SHIFT_OP[1] ? Shifter_In[BITS - 1 : BITS - 1] : 1'b0} : Shifter_In);

	assign imSF_1 = SHIFT_OP[0] ? 
					(SHAMT[1] ? {SHIFT_OP[1] ? {2{imSF_0[BITS - 1]}} : 2'b0, imSF_0[BITS - 1 : 2]} : imSF_0) : 
					(SHAMT[1] ? {imSF_0[BITS - 3 : 0], SHIFT_OP[1] ? imSF_0[BITS - 1 : BITS - 2] : 2'b0} : imSF_0);

	assign imSF_2 = SHIFT_OP[0] ? 
					(SHAMT[2] ? {SHIFT_OP[1] ? {4{imSF_1[BITS - 1]}} : 4'b0, imSF_1[BITS - 1 : 4]} : imSF_1) : 
					(SHAMT[2] ? {imSF_1[BITS - 5 : 0], SHIFT_OP[1] ? imSF_1[BITS - 1 : BITS - 4] : 4'b0} : imSF_1);

	assign imSF_3 = SHIFT_OP[0] ? 
					(SHAMT[3] ? {SHIFT_OP[1] ? {8{imSF_2[BITS - 1]}} : 8'b0, imSF_2[BITS - 1 : 8]} : imSF_2) : 
					(SHAMT[3] ? {imSF_2[BITS - 9 : 0], SHIFT_OP[1] ? imSF_2[BITS - 1 : BITS - 8] : 8'b0} : imSF_2);

	assign Shifter_Out  = SHIFT_OP[0] ? 
					(SHAMT[4] ? {SHIFT_OP[1] ? {16{imSF_3[BITS - 1]}} : 16'b0, imSF_3[BITS - 1 : 16]} : imSF_3) : 
					(SHAMT[4] ? {imSF_3[BITS - 17 : 0], SHIFT_OP[1] ? imSF_3[BITS - 1 : BITS - 16] : 16'b0} : imSF_3);
endmodule
`default_nettype wire