///////////////////////////////////////////////////////////////////////////////
// Program: DECODE_TOP.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level DECODE Pipeline Stage
//
//  - Inputs:
//      clk:    			Global Clock
//      STALL:    			Global STALL Signal
//      IF_ID_Inst:    		Instruction Fetched from Memory
//      IF_ID_PC:    		Current PC Address
//      WB_DATA:      		Register File Destination Data
//      IF_ID_PC_INC:      	Pass Through PC_INC from Fetch Stage
//      IF_ID_HLT:      	Pass Through HALT Flag from Fetch Stage
//		MEM_WB_RD:			Register File Dest ADDR from WB Stage
//		MEM_WB_REG_WRITE:	Register File WEN from WB Stage
//		FORWARD_DECODE_A:	Decoding Forwarding Mux A Select
//		FORWARD_DECODE_B:	Decoding Forwarding Mux B Select
//		EX_MEM_EXECUTE_OUT:	Forwarded Execute Stage Output
//		LWCP_STALL:			Dedicated LWPC Global Stall
//
//  - Outputs:
//      ID_PC_SRC:			PC Next Source
//      ID_TARGET_ADDR:		Computed Target Address for Branch / Jump Instructions
//      ID_EX_IMM32:		Pipelined Computed 32-Bit Immediate for Current Instruction
//      ID_EX_WB_SRC_SEL:	Pipelined Mux Select for Write Back data to Register File
//      ID_EX_MEM_WRITE:	Pipelined Data Memory Write Enable
//      ID_EX_MEM_READ:		Pipelined Data Memory Read Enable
//      ID_EX_MEM_TYPE:		Pipelined Data Memory Access Type
//      ID_EX_EX_OUT_SEL: 	Pipelined Execute Stage Output Selection
//      ID_EX_SHAMT:		Pipelined Shift Amount for ALU Shift Operations
//      ID_EX_ALU_OP:		Pipelined ALU Operation Control
//      ID_EX_ALU_A_SRC:	Pipelined Mux Select for ALU Source A
//      ID_EX_ALU_B_SRC:	Pipelined Mux Select for ALU Source B
//      ID_EX_SRA:			Pipelined Register File Data Output 1
//      ID_EX_SRB:			Pipelined Register File Data Output 2
//      ID_EX_RD:			Pipelined Register File Destination Data Address
//      ID_EX_REG_WRITE:	Pipelined Register File Write Enable
//      ID_EX_PC:			Pipelined Program Counter
//      ID_EX_PC_INC:		Pipelined Program Counter+
//      ID_EX_HLT:			Pipelined HALT Flag
//      ID_RS1:				SR1 Reg File Address
//      ID_RS2:				SR2 Reg File Address
//      ID_BRANCH:			Branch Instruction Flag
//      ID_JUMPR:			JUMP_R Instruction Flag
//		ID_EX_RS1:			Pipelined SR1 Reg File Address
//		ID_EX_RS2:			Pipelined SR2 Reg File Address
//		ID_MEM_WRITE:		Currently Decoded Memory Write Enable
//		ID_REG_WRITE:		Currently Decoded Reg File Write Enable
//		ID_I_TYPE:			Immediate-Type Instruction Flag
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module DECODE_TOP (clk, rst_n, IF_ID_Inst, IF_ID_PC, WB_DATA, ID_PC_SRC,
		ID_TARGET_ADDR, ID_EX_IMM32, ID_EX_WB_SRC_SEL, ID_EX_MEM_WRITE,
		ID_EX_MEM_READ, ID_EX_MEM_TYPE, ID_EX_EX_OUT_SEL, ID_EX_SHAMT,
		ID_EX_ALU_OP, ID_EX_ALU_A_SRC, ID_EX_ALU_B_SRC, ID_EX_SRA, ID_EX_SRB,
		ID_EX_RD, ID_EX_REG_WRITE, ID_EX_PC, IF_ID_PC_INC, ID_EX_PC_INC,
		IF_ID_HLT, ID_EX_HLT, MEM_WB_RD, MEM_WB_REG_WRITE, ID_RS1, ID_RS2,
		ID_BRANCH, ID_JUMPR, ID_EX_RS1, ID_EX_RS2, FORWARD_DECODE_A,
		FORWARD_DECODE_B, EX_MEM_EXECUTE_OUT, ID_MEM_WRITE, ID_REG_WRITE,
		STALL, ID_I_TYPE, LWCP_STALL);
			
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] IF_ID_Inst, IF_ID_PC, WB_DATA, IF_ID_PC_INC,
		EX_MEM_EXECUTE_OUT;
	input logic [4:0] MEM_WB_RD;
	input logic clk, rst_n, IF_ID_HLT, MEM_WB_REG_WRITE, FORWARD_DECODE_A, 
		FORWARD_DECODE_B, STALL, LWCP_STALL;
	
	output logic [BITS - 1 : 0] ID_TARGET_ADDR, ID_EX_IMM32, ID_EX_SRA,
		ID_EX_SRB, ID_EX_PC, ID_EX_PC_INC;
		
	output logic [4:0] ID_EX_SHAMT, ID_EX_RD, ID_RS1, ID_RS2, ID_EX_RS1,
		ID_EX_RS2;
	output wb_mux_t ID_EX_WB_SRC_SEL;
	output mem_data_t ID_EX_MEM_TYPE;
	output alu_t ID_EX_ALU_OP;
	output execute_mux_t ID_EX_EX_OUT_SEL;
	output logic ID_PC_SRC, ID_EX_MEM_WRITE, ID_EX_MEM_READ, ID_EX_ALU_A_SRC,
		ID_EX_ALU_B_SRC, ID_EX_REG_WRITE, ID_EX_HLT, ID_BRANCH, ID_JUMPR,
		ID_MEM_WRITE, ID_REG_WRITE, ID_I_TYPE;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] TARGET_ADDR_SRA, IMM32, SRA, SRB,
		DATA1, DATA2;
	logic [8:0] IMM_SEL;
	logic [4:0] RD, SHAMT;
	logic BRANCH, TARGET_SRC_SEL, MEM_READ, ALU_A_SRC,
		ALU_B_SRC;
		
	mem_data_t MEM_TYPE;
	branch_t BRANCH_CCC;
	wb_mux_t WB_SRC_SEL;
	execute_mux_t EX_OUT_SEL;
	alu_t ALU_OP;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Register Address Decode
	assign ID_RS1 = IF_ID_Inst[19:15];
	assign ID_RS2 = IF_ID_Inst[24:20];
	assign RD = IF_ID_Inst[11:7];
	
	// SHAMT Decode
	assign SHAMT = IF_ID_Inst[24:20];
	
	// Immediate Generation Unit
	IMM_GEN imm_gen(.I(IF_ID_Inst), .IMM_SEL(IMM_SEL), .IMM32(IMM32));
	
	// Register File Instantiation
	REG_FILE rf(.clk(clk), .rst_n(rst_n), .SR1(ID_RS1), .SR2(ID_RS2), .RD(MEM_WB_RD), .DEST_DATA(WB_DATA),
					.WEN(MEM_WB_REG_WRITE & (~LWCP_STALL)), .Data1(DATA1), .Data2(DATA2));
	
	// Control Unit
	CU control_unit(.OPCODE(opcode_t'(IF_ID_Inst[6:0])), .FUNC3(IF_ID_Inst[14:12]),
		.BIT30(IF_ID_Inst[30]), .BRANCH(BRANCH), .ALU_OP(ALU_OP), .PC_SRC(ID_PC_SRC),
		.MEM_WRITE(ID_MEM_WRITE), .MEM_DATA_TYPE(MEM_TYPE), .MEM_READ(MEM_READ),
		.REG_WRITE(ID_REG_WRITE), .WB_SRC_SEL(WB_SRC_SEL), .IMM_SEL(IMM_SEL),
		.TARGET_SRC_SEL(TARGET_SRC_SEL), .BRANCH_CCC(BRANCH_CCC), .ALU_A_SRC(ALU_A_SRC),
		.ALU_B_SRC(ALU_B_SRC), .EXECUTE_OUT_SEL(EX_OUT_SEL), .ID_BRANCH(ID_BRANCH),
		.ID_JUMPR(ID_JUMPR), .I_TYPE(ID_I_TYPE));
		
	// Decode Forwarding Muxes
	assign SRA = (FORWARD_DECODE_A) ? (EX_MEM_EXECUTE_OUT) : (DATA1);
	assign SRB = (FORWARD_DECODE_B) ? (EX_MEM_EXECUTE_OUT) : (DATA2);
	
	// BR BOOL Comparison Logic
	BR_BOOL br_comp(.SR1(SRA), .SR2(SRB), .BRANCH_CCC(BRANCH_CCC), .BRANCH(BRANCH));
	
	// Branch / Jump Target Calculation
	assign TARGET_ADDR_SRA = (TARGET_SRC_SEL) ? (SRA) : (IF_ID_PC);
	assign ID_TARGET_ADDR = TARGET_ADDR_SRA + IMM32;
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Pipeline Registers //////////////////////
    ////////////////////////////////////////////////////////////
	always_ff @(posedge clk) begin
		if (~rst_n | STALL) begin
			ID_EX_IMM32 <= 'h0;
			ID_EX_WB_SRC_SEL <= wb_mux_t'('h0);
			ID_EX_MEM_WRITE <= 'h0;
			ID_EX_MEM_READ <= 'h0;
			ID_EX_MEM_TYPE <= mem_data_t'('h0);
			ID_EX_EX_OUT_SEL <= execute_mux_t'('h0);
			ID_EX_SHAMT <= 'h0;
			ID_EX_ALU_OP <= alu_t'('h0);
			ID_EX_ALU_A_SRC <= 'h0;
			ID_EX_ALU_B_SRC <= 'h0;
			ID_EX_SRA <= 'h0;
			ID_EX_SRB <= 'h0;
			ID_EX_RD <= 'h0;
			ID_EX_REG_WRITE <= 'h0;
			ID_EX_PC <= 'h0;
			ID_EX_PC_INC <= 'h4;
			ID_EX_HLT <= 'h0;
			ID_EX_RS1 <= 'h0;
			ID_EX_RS2 <= 'h0;
		end
		else if (~LWCP_STALL) begin
			ID_EX_IMM32 <= IMM32;
			ID_EX_WB_SRC_SEL <= WB_SRC_SEL;
			ID_EX_MEM_WRITE <= ID_MEM_WRITE;
			ID_EX_MEM_READ <= MEM_READ;
			ID_EX_MEM_TYPE <= MEM_TYPE;
			ID_EX_EX_OUT_SEL <= EX_OUT_SEL;
			ID_EX_SHAMT <= SHAMT;
			ID_EX_ALU_OP <= ALU_OP;
			ID_EX_ALU_A_SRC <= ALU_A_SRC;
			ID_EX_ALU_B_SRC <= ALU_B_SRC;
			ID_EX_SRA <= SRA;
			ID_EX_SRB <= SRB;
			ID_EX_RD <= RD;
			ID_EX_REG_WRITE <= ID_REG_WRITE;
			ID_EX_PC <= IF_ID_PC;
			ID_EX_PC_INC <= IF_ID_PC_INC;
			ID_EX_HLT <= IF_ID_HLT;
			ID_EX_RS1 <= ID_RS1;
			ID_EX_RS2 <= ID_RS2;
		end
	end
endmodule
`default_nettype wire