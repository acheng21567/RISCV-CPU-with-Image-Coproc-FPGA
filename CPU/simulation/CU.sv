///////////////////////////////////////////////////////////////////////////////
// Program: CU.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Control Unit
//
//  - Inputs:
//      OPCODE:    		Instruction[6:0] Opcode
//      FUNC3:    		Instruction[14:12] Function Bits for Operation Selection
//      BIT30:    		Additional Instruction BIT30 for FUNC7 Operation Selection
//      BRANCH:     	Branch Flag from BR_BOOL Unit Signifying Valid Branch
//						Conditions
//
//  - Outputs:
//      ALU_OP:			ALU Operation Control signifying current operation
//							to execute
//
//		PC_SRC:			Next PC Selection -> (1) JMP / BR; else (0)
//		REG_WRITE:		Register File Write Enable
//		MEM_WRITE:		Data Memory Write Enable
//		MEM_READ:		Data Memory Read Enable
//		MEM_DATA_TYPE:	Data Type for Memory Access
//		WB_SRC_SEL:		Source Selection in Write Back Phase to Register File
//							- 00: ALU Output (ALU Operations)
//							- 01: Data Memory Output (Loads)
//							- 10: PC+ (JMPx Instructions)
//		IMM_SEL:		Selection Vector of Immediate Format to the Immediate
//							generation unit:
//							- 000: I-Type
//							- 001: S-Type
//							- 010: B-Type
//							- 011: U-Type
//							- 100: J-Type
//		TARGET_SRC_SEL:	Source Selection for Branch / Jump Target Calculation
//							(0) -> BR / JAL use PC; (1) -> JALR use SR1
//		BRANCH_CCC:		Branch Condition Type
//		ALU_A_SRC:		ALU Operand A Source Selection:
//							(1) -> AUIPC uses PC; (0) -> Else use SR1 
//		ALU_B_SRC:		ALU Operand B Source Selection:
//							(1) -> R-Type Instructions use SR2; (0) -> Else use IMM32
//		EXECUTE_OUT_SEL: Selection of EXECUTE Top's Output:
//							(01) -> IMM32 chosen for LUI; (00) -> ALU Out;
//							(1x) -> PC_INC for AUIPC
//		ID_BRANCH:		Branch Instruction Flag
//		ID_JUMPR:		JUMP_R Instruction Flag
//		I_TYPE:			Immediate-Type Instruction Flag
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module CU (OPCODE, FUNC3, BIT30, BRANCH, ALU_OP, PC_SRC, MEM_WRITE,
			MEM_DATA_TYPE, MEM_READ, REG_WRITE, WB_SRC_SEL, IMM_SEL,
			TARGET_SRC_SEL, BRANCH_CCC, ALU_A_SRC, ALU_B_SRC, EXECUTE_OUT_SEL,
			ID_BRANCH, ID_JUMPR, I_TYPE);
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input opcode_t OPCODE;
	input wire [2:0] FUNC3;
	input wire BIT30, BRANCH;
	output alu_t ALU_OP;
	output mem_data_t MEM_DATA_TYPE;
	output branch_t BRANCH_CCC;
	output logic [8:0] IMM_SEL;
	output wb_mux_t WB_SRC_SEL;
	output execute_mux_t EXECUTE_OUT_SEL;
	output logic PC_SRC, MEM_WRITE, MEM_READ, REG_WRITE, TARGET_SRC_SEL,
					ALU_A_SRC, ALU_B_SRC, ID_BRANCH, ID_JUMPR, I_TYPE;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic R, I, S, B, U, J; // Instruction Format Signification
	logic branch_en, jump_en; // Final Branch & Jump Signifiers
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Immediate-Type Operation
	assign I_TYPE = I;
	
	// Branch Instruction Flag for the Forwarding Unit
	assign ID_BRANCH = B;
	
	// JUMP_R Instruction Flag
	assign ID_JUMPR = (OPCODE == JALR_i);
	
	// EXECUTE Output Selection
	assign EXECUTE_OUT_SEL = jump_en ? (PC_INC_o) : // Select PC_INC to Output for JMPx
								(OPCODE == LUI_i) ? (IMM_o) : (ALU_o); // Select Immediate to Output for LUI
	
	// Source Selection for ALU Operand A
	assign ALU_A_SRC = (OPCODE == AUIPC_i); // Select PC for ALU Addition
	
	// Source Selection for ALU Operand B
	assign ALU_B_SRC = R; // Select RegFile SR2 for R Type Instructions

	// Target Address Calculation Source Select
	assign TARGET_SRC_SEL = (OPCODE == JALR_i);
	
	// Immediate Encoding Selection Bit Vector
	assign IMM_SEL = {U, (U || J), {(I || S || J), (I || S || B)},
						U, {(I || J), (S || B)}, {I, S}};
	
	// Write Back Muxing Select
	assign WB_SRC_SEL = (OPCODE == LOAD_i) ? (DATA_MEM_wbmux) : // Data Memory Output
						(EX_OUT_wbmux); // Execute Output 

	// Register File Write Enable
	assign REG_WRITE = R | I | U | J;
	
	// Memory Access Data Type 
	assign MEM_DATA_TYPE = mem_data_t'(FUNC3);
	
	// Memory Read Enable -> Load Instructions
	assign MEM_READ = (OPCODE == LOAD_i);
	
	// Memory Write Enable -> Store Instructions
	assign MEM_WRITE = S;
	
	// Determine if Valid Branch Instruction & BRANCH Conditions Met
	assign branch_en = BRANCH && B;
	
	// Branch Condition Codes for BR_BOOL Unit
	assign BRANCH_CCC = branch_t'(FUNC3);
	
	// Determine if Jump Instruction
	assign jump_en = (OPCODE == JALR_i) || J;
	
	// PC_SRC Selection
	assign PC_SRC = branch_en || jump_en;
	
	// Instruction Type Encoding
	assign R = (OPCODE == ALU_i);
	assign I = (OPCODE == JALR_i) || (OPCODE == LOAD_i) || (OPCODE == ALUI_i);
	assign S = (OPCODE == STORE_i);
	assign B = (OPCODE == BR_i);
	assign U = (OPCODE == LUI_i) || (OPCODE == AUIPC_i);
	assign J = (OPCODE == JAL_i);
	
	// ALU OP Encoding
	assign ALU_OP = ((R) && (FUNC3 == 3'b000) && BIT30) ? (SUB) :
					(OPCODE == LOAD_i) ? (ADD) :
					((R || I) && (FUNC3 == 3'b010)) ? (SLT) :
					((R || I) && (FUNC3 == 3'b011)) ? (SLTU) :
					((R || I) && (FUNC3 == 3'b100)) ? (XOR) :
					((R || I) && (FUNC3 == 3'b110)) ? (OR) :
					((R || I) && (FUNC3 == 3'b111)) ? (AND) :
					((R || I) && (FUNC3 == 3'b001)) ? (SLL) :
					((R || I) && (FUNC3 == 3'b101) && BIT30) ? (SRA) :
					((R || I) && (FUNC3 == 3'b101) && ~BIT30) ? (SRL) :
					(ADD); // Default to ADD (Load, Store, AUIPC, etc...)
endmodule
`default_nettype wire