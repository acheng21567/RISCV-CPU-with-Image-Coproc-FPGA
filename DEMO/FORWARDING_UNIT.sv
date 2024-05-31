///////////////////////////////////////////////////////////////////////////////
// Program: FORWARDING_UNIT.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Pipeline Forwarding Unit
//
//  - Inputs:
//      ID_RS1:    			Decode Stage Reg File SRC 1 ADDR
//      ID_RS2:    			Decode Stage Reg File SRC 2 ADDR
//      ID_BRANCH:    		Decode Stage BRANCH Flag
//      ID_JUMPR:    		Decode Stage JUMP_R Flag
//      ID_EX_RS1:    		Pipelined ID/EX Reg File SRC 1 ADDR
//      ID_EX_RS2:    		Pipelined ID/EX Reg File SRC 2 ADDR
//      ID_EX_REG_WRITE:   	Pipelined ID/EX Reg File Write Enable
//      ID_EX_MEM_WRITE:   	Pipelined ID/EX Memory Write Enable
//      EX_MEM_RS2:    		Pipelined EX/MEM Reg File SRC 2 ADDR
//      EX_MEM_REG_WRITE:   Pipelined EX/MEM Reg File Write Enable
//      EX_MEM_MEM_WRITE:  	Pipelined EX/MEM Memory Write Enable
//		EX_MEM_RD:			Pipelined EX/MEM Reg File Dest ADDR
//		MEM_WB_RD:			Pipelined MEM/WB Reg File Dest ADDR
//      MEM_WB_REG_WRITE:   Pipelined MEM/WB Reg File Write Enable
//
//  - Outputs:
//      FORWARD_EXECUTE_A:	Execute Stage Forwarding Mux A Select
//		FORWARD_EXECUTE_B:	Execute Stage Forwarding Mux B Select
//							- 00: NO FORWARDING
//							- 01: MEM-TO-EX FORWARDING
//							- 1X: EX-TO-EX FORWARDING
//		FORWARD_MEMORY:		Memory Stage Forwarding Mux Select
//							- 0: NO FORWARDING
//							- 1: MEM-TO-MEM FORWARDING
//		FORWARD_DECODE_A:	Decode Stage Forwarding Mux A Select
//		FORWARD_DECODE_B:	Decode Stage Forwarding Mux B Select
//							- 0: NO FORWARDING
//							- 1: EX-TO-ID FORWARDING
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module FORWARDING_UNIT (ID_RS1, ID_RS2, ID_BRANCH, ID_JUMPR, ID_EX_RS1, ID_EX_RS2,
		ID_EX_REG_WRITE, ID_EX_MEM_WRITE, EX_MEM_RS2, EX_MEM_REG_WRITE,
		EX_MEM_MEM_WRITE, EX_MEM_RD, MEM_WB_RD, MEM_WB_REG_WRITE,
		FORWARD_EXECUTE_A, FORWARD_EXECUTE_B, FORWARD_MEMORY, FORWARD_DECODE_A,
		FORWARD_DECODE_B);

	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [4:0] ID_RS1, ID_RS2, ID_EX_RS1, ID_EX_RS2, EX_MEM_RS2,
		EX_MEM_RD, MEM_WB_RD;
	input logic ID_BRANCH, ID_JUMPR, ID_EX_REG_WRITE, ID_EX_MEM_WRITE,
		EX_MEM_REG_WRITE, EX_MEM_MEM_WRITE, MEM_WB_REG_WRITE;
		
	output logic [1:0] FORWARD_EXECUTE_A, FORWARD_EXECUTE_B;
	output logic FORWARD_MEMORY, FORWARD_DECODE_A, FORWARD_DECODE_B;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic ex_to_ex_condition, mem_to_ex_condition, enable_execute, 
		ex_to_id_condition;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Logic Sharing
	assign enable_execute = (ID_EX_REG_WRITE | ID_EX_MEM_WRITE);
	
	///////////////////////////////////
	// Execute-to-Execute Forwarding //
	///////////////////////////////////
	assign ex_to_ex_condition = EX_MEM_REG_WRITE & (EX_MEM_RD != 0) & enable_execute;
	
	// Priority to Ex-to-Ex forwarding with Execute Muxes
	assign FORWARD_EXECUTE_A[1] = ex_to_ex_condition & (EX_MEM_RD == ID_EX_RS1);
	assign FORWARD_EXECUTE_B[1] = ex_to_ex_condition & (EX_MEM_RD == ID_EX_RS2);
	
	
	//////////////////////////////////
	// Memory-to-Execute Forwarding //
	//////////////////////////////////
	assign mem_to_ex_condition = MEM_WB_REG_WRITE & (MEM_WB_RD != 0) & enable_execute;
	
	// Second Priority to Mem-to-Ex forwarding with Execute Muxes
	assign FORWARD_EXECUTE_A[0] = mem_to_ex_condition & (MEM_WB_RD == ID_EX_RS1);
	assign FORWARD_EXECUTE_B[0] = mem_to_ex_condition & (MEM_WB_RD == ID_EX_RS2);
	
	
	/////////////////////////////////
	// Memory-to-Memory Forwarding //
	/////////////////////////////////
	assign FORWARD_MEMORY = MEM_WB_REG_WRITE & (MEM_WB_RD != 0) &
		EX_MEM_MEM_WRITE & (MEM_WB_RD == EX_MEM_RS2);
	
	
	//////////////////////////////////
	// Execute-to-Decode Forwarding //
	//////////////////////////////////
	assign ex_to_id_condition = EX_MEM_REG_WRITE & (EX_MEM_RD != 0);

	assign FORWARD_DECODE_A = ex_to_id_condition & (ID_BRANCH | ID_JUMPR) &
		(EX_MEM_RD == ID_RS1);
	assign FORWARD_DECODE_B = ex_to_id_condition & ID_BRANCH & (EX_MEM_RD == ID_RS2);
endmodule
`default_nettype wire