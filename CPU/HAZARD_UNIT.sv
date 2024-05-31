///////////////////////////////////////////////////////////////////////////////
// Program: HAZARD_UNIT.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Pipeline Hazard Unit
//
//  - Inputs:
//      ID_EX_MEM_READ:		Pipelined ID/EX Memory Read Enable
//      ID_MEM_WRITE:		Decode Stage Memory Write Enable
//      ID_REG_WRITE:		Decode Stage Reg File Write Enable
//      ID_EX_RD:			Pipelined ID/EX Reg File Dest Addr
//      ID_RS1:    			Decode Stage Reg File SRC 1 ADDR
//      ID_RS2:    			Decode Stage Reg File SRC 2 ADDR
//		ID_BRANCH:			Decode Stage Branch Instruction Flag
//		ID_JUMPR:			Decode Stage Jump R Instruction Flag
//		ID_EX_REG_WRITE:	Pipelined ID/EX Reg File Write Enable
//      EX_MEM_MEM_READ:	Pipelined EX/MEM Memory Read Enable
//      EX_MEM_RD:			Pipelined EX/MEM Reg File Dest Addr
//		ID_PC_SRC:			Decode Stage PC_SRC for Control Flow Taken
//		ID_I_TYPE:			Decode Stage Immediate-Type Instruction
//
//  - Outputs:
//      STALL:				Flag Signifying Processor STALL on FETCH & DECODE
//      FLUSH:				Flag Signifying Processor FLUSH on FETCH
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module HAZARD_UNIT (ID_EX_MEM_READ, ID_MEM_WRITE, ID_REG_WRITE, ID_EX_RD,
		ID_RS1, ID_RS2, ID_BRANCH, ID_JUMPR, ID_EX_REG_WRITE, EX_MEM_MEM_READ,
		EX_MEM_RD, ID_PC_SRC, STALL, FLUSH, ID_I_TYPE);

	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [4:0] ID_EX_RD, ID_RS1, ID_RS2, EX_MEM_RD;
	input logic ID_EX_MEM_READ, ID_MEM_WRITE, ID_REG_WRITE, ID_BRANCH, ID_JUMPR,
		ID_EX_REG_WRITE, EX_MEM_MEM_READ, ID_PC_SRC, ID_I_TYPE;
	output logic STALL, FLUSH;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic load_to_use, branch_jumpr, load_to_branch_jumpr;
	

		
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Common Load-to-Use Stall Case
	assign load_to_use = (ID_EX_MEM_READ) & (ID_MEM_WRITE | ID_REG_WRITE)
			& (ID_EX_RD != 0) & ((ID_RS1 == ID_EX_RD) |
				((ID_RS2 == ID_EX_RD) & ~(ID_MEM_WRITE | ID_I_TYPE)));
				
	// TODO: MUST AVOID STALLS FOR I-TYPE INSTRUCTIONS BECAUSE WE DO NOT USE SR2
				
	// Common Branch / JumpR Stall Case
	assign branch_jumpr = (ID_BRANCH | ID_JUMPR) & (ID_EX_REG_WRITE)
			& (ID_EX_RD != 0) & ((ID_RS1 == ID_EX_RD) |
				((ID_RS2 == ID_EX_RD) & (~ID_JUMPR)));
	
	// Special Load-To-Use-Branch_JumpR Case
	assign load_to_branch_jumpr = (ID_BRANCH | ID_JUMPR) & (EX_MEM_MEM_READ)
			& (EX_MEM_RD != 0) & ((EX_MEM_RD == ID_RS1) |
				((EX_MEM_RD == ID_RS2) & (~ID_JUMPR)));
				
	// Global Stall
	assign STALL = load_to_use | branch_jumpr | load_to_branch_jumpr;
	
	// Global FLUSH
	assign FLUSH = ID_PC_SRC & (~STALL);
endmodule
`default_nettype wire