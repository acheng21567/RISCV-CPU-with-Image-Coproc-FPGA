///////////////////////////////////////////////////////////////////////////////
// Program: EXECUTE_TOP.v
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level EXECUTE Pipeline Stage
//  - Inputs:
//      ID_EX_SHAMT:      		ALU Shift Amount for Shifter TOP
//      ID_EX_ALU_OP:     		ALU Operation Control
//      ID_EX_ALU_A_SRC:		Mux Select for ALU Source A
//      ID_EX_ALU_B_SRC:		Mux Select for ALU Source B
//		ID_EX_IMM32:			32-Bit Immediate Operand
//		ID_EX_SRA:				32-Bit ALU Operand A
//		ID_EX_SRB:				32-Bit ALU Operand B
//		ID_EX_PC:				Program Counter of Instruction in Execute Stage
//		ID_EX_EX_OUT_SEL:		Execute Output Mux Select
//		ID_EX_PC_INC:			32-Bit Incremented PC for AUIPC Instructions
//		ID_EX_WB_SRC_SEL:		Pass Through WB_SRC_SEL from Decode Stage
//		ID_EX_MEM_WRITE:		Pass Through MEM_WRITE from Decode Stage
//		ID_EX_MEM_READ:			Pass Through MEM_READ from Decode Stage
//		ID_EX_MEM_TYPE:			Pass Through MEM_DATA_TYPE from Decode Stage
//		ID_EX_RD:				Pass Through Reg File Dest Addr from Decode Stage
//		ID_EX_REG_WRITE:		Pass Through Reg File WEN from Decode Stage
//		clk:					Global Clock
//		rst_n:					Active Low Reset
//		ID_EX_HLT:				Pass Through HALT Flag
//		ID_EX_RS2:				Pass Through Reg File SRC2 ADDR
//		FORWARD_EXECUTE_A:		Forwarding Mux A Select
//		FORWARD_EXECUTE_B:		Forwarding Mux B Select
//		WB_DATA:				Forwarded Output from Write Back Stage
//		LWCP_STALL:				Dedicated LWCP Global Stall
//
//  - Outputs:
//      EX_MEM_EXECUTE_OUT:		Pipelined Execute Output Data
//		EX_MEM_MEM_DATA_IN:   	Pipelined Data Memory Input
//		EX_MEM_WB_SRC_SEL:   	Pipelined WB_SRC_SEL
//		EX_MEM_MEM_WRITE:   	Pipelined MEM_WRITE
//		EX_MEM_MEM_READ:   		Pipelined MEM_READ
//		EX_MEM_MEM_TYPE:   		Pipelined MEM_DATA_TYPE
//		EX_MEM_RD:   			Pipelined Reg File Dest Addr
//		EX_MEM_REG_WRITE:   	Pipelined Reg File WEN
//		EX_MEM_HLT:   			Pipelined HLT Flag
//		EX_MEM_RS2:   			Pipelined Reg File SRC2 ADDR
//		EX_MEM_PC:   			Pipelined Program Counter
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module EXECUTE_TOP (ID_EX_SHAMT, ID_EX_ALU_OP, ID_EX_ALU_A_SRC, ID_EX_ALU_B_SRC,
		ID_EX_IMM32, ID_EX_SRA, ID_EX_SRB, ID_EX_PC, ID_EX_EX_OUT_SEL,
		ID_EX_PC_INC, EX_MEM_EXECUTE_OUT, EX_MEM_MEM_DATA_IN, ID_EX_WB_SRC_SEL,
		EX_MEM_WB_SRC_SEL, ID_EX_MEM_WRITE, EX_MEM_MEM_WRITE, ID_EX_MEM_READ,
		EX_MEM_MEM_READ, ID_EX_MEM_TYPE, EX_MEM_MEM_TYPE, ID_EX_RD, EX_MEM_RD, 
		ID_EX_REG_WRITE, EX_MEM_REG_WRITE, clk, rst_n, ID_EX_HLT, EX_MEM_HLT,
		ID_EX_RS2, EX_MEM_RS2, FORWARD_EXECUTE_A, FORWARD_EXECUTE_B, WB_DATA,
		EX_MEM_PC, LWCP_STALL);
		
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] ID_EX_IMM32, ID_EX_SRA, ID_EX_SRB, ID_EX_PC,
		ID_EX_PC_INC, WB_DATA;
		
	input logic [4:0] ID_EX_SHAMT, ID_EX_RD, ID_EX_RS2;
	input logic [1:0] FORWARD_EXECUTE_A, FORWARD_EXECUTE_B;
	input logic ID_EX_ALU_A_SRC, ID_EX_ALU_B_SRC, ID_EX_MEM_WRITE,
		ID_EX_MEM_READ, ID_EX_REG_WRITE, ID_EX_HLT, clk, rst_n, LWCP_STALL;
		
	input wb_mux_t ID_EX_WB_SRC_SEL;
	input execute_mux_t ID_EX_EX_OUT_SEL;
	input alu_t ID_EX_ALU_OP;
	input mem_data_t ID_EX_MEM_TYPE;
	
	output logic [BITS - 1 : 0] EX_MEM_EXECUTE_OUT, EX_MEM_MEM_DATA_IN, EX_MEM_PC;
	output logic [4:0] EX_MEM_RD, EX_MEM_RS2;
	output logic EX_MEM_MEM_WRITE, EX_MEM_MEM_READ, EX_MEM_REG_WRITE, EX_MEM_HLT;
	output wb_mux_t EX_MEM_WB_SRC_SEL;
	output mem_data_t EX_MEM_MEM_TYPE;


	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] A_IN, B_IN, ALU_OUT,  EXECUTE_OUT, SRA, SRB;
	logic [4:0] SHAMT_IN;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// Forwarding Mux A
	assign SRA = FORWARD_EXECUTE_A[1] ? (EX_MEM_EXECUTE_OUT) : // Ex-to-Ex Case
				(FORWARD_EXECUTE_A[0] ? (WB_DATA) : // Mem-to-Ex Case
				(ID_EX_SRA)); // No Forwarding Case
	
	// Forwarding Mux A
	assign SRB = FORWARD_EXECUTE_B[1] ? (EX_MEM_EXECUTE_OUT) : // Ex-to-Ex Case
				(FORWARD_EXECUTE_B[0] ? (WB_DATA) : // Mem-to-Ex Case
				(ID_EX_SRB)); // No Forwarding Case
	
	// Selection of A & B Inputs to ALU
	assign A_IN = ID_EX_ALU_A_SRC ? (ID_EX_PC) : (SRA);
	assign B_IN = ID_EX_ALU_B_SRC ? (SRB) : (ID_EX_IMM32);
	
	// Selection of SHAMT based on R type instruction -> USE SRB
	assign SHAMT_IN = ID_EX_ALU_B_SRC ? (SRB) : (ID_EX_SHAMT);
	
	// ALU Instantiation
	ALU alu_top(.A_in(A_IN), .B_in(B_IN), .ALU_OP(ID_EX_ALU_OP), .SHAMT(SHAMT_IN),
				.ALU_OUT(ALU_OUT));
				
	// Selection of ALU, IMM32, PC_INC for EXECUTE Output	
	assign EXECUTE_OUT = (ID_EX_EX_OUT_SEL == PC_INC_o) ? (ID_EX_PC_INC) :
							(ID_EX_EX_OUT_SEL == IMM_o) ? (ID_EX_IMM32) :
								(ALU_OUT);
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Pipeline Registers //////////////////////
    ////////////////////////////////////////////////////////////
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			EX_MEM_EXECUTE_OUT <= 'h0;
			EX_MEM_MEM_DATA_IN <= 'h0;
			EX_MEM_WB_SRC_SEL <= wb_mux_t'('h0);
			EX_MEM_MEM_WRITE <= 'h0;
			EX_MEM_MEM_READ <= 'h0;
			EX_MEM_MEM_TYPE <= mem_data_t'('h0);
			EX_MEM_RD <= 'h0;
			EX_MEM_REG_WRITE <= 'h0;
			EX_MEM_HLT <= 'h0;
			EX_MEM_RS2 <= 'h0;
			EX_MEM_PC <= 'h0;
		end
		else if (~LWCP_STALL) begin
			EX_MEM_EXECUTE_OUT <= EXECUTE_OUT;
			EX_MEM_MEM_DATA_IN <= SRB;
			EX_MEM_WB_SRC_SEL <= ID_EX_WB_SRC_SEL;
			EX_MEM_MEM_WRITE <= ID_EX_MEM_WRITE;
			EX_MEM_MEM_READ <= ID_EX_MEM_READ;
			EX_MEM_MEM_TYPE <= ID_EX_MEM_TYPE;
			EX_MEM_RD <= ID_EX_RD;
			EX_MEM_REG_WRITE <= ID_EX_REG_WRITE;
			EX_MEM_HLT <= ID_EX_HLT;
			EX_MEM_RS2 <= ID_EX_RS2;
			EX_MEM_PC <= ID_EX_PC;
		end
	end
endmodule
`default_nettype wire