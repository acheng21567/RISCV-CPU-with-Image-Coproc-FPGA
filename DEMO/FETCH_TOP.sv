///////////////////////////////////////////////////////////////////////////////
// Program: FETCH_TOP.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level FETCH Pipeline Stage
//
//  - Inputs:
//      clk:    			Global Clock 
//      rst_n:    			Global Active Low Reset 
//      STALL:    			Global STALL
//      FLUSH:    			Global FLUSH
//      TARGET_ADDR:    	PC Target Address for Jump / Branch Instructions
//      PC_SRC:    			PC Next Selection
//      LWCP_STALL:    		Dedicated LWCP Global Stall
//
//  - Outputs:
//      IF_ID_Inst:			Pipelined Output Instruction from I-MEM
//      IF_ID_PC:			Pipelined Current PC
//      IF_ID_PC_INC:		Pipelined Current Incremented PC
//		IF_ID_HLT:			Pipelined Global Halt Flag
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module FETCH_TOP (clk, rst_n, TARGET_ADDR, PC_SRC, IF_ID_Inst, IF_ID_PC,
		IF_ID_PC_INC, IF_ID_HLT, STALL, FLUSH, wdata_data, wdata_addr, we_boot,
		bootloading, LWCP_STALL);
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] TARGET_ADDR;
	input wire PC_SRC, clk, rst_n, STALL, FLUSH, LWCP_STALL;
	output logic [BITS - 1 : 0] IF_ID_Inst, IF_ID_PC, IF_ID_PC_INC;
	output logic IF_ID_HLT;
	
	input logic [BITS - 1 : 0] wdata_data;
	input logic [ADDRIW - 1 : 0] wdata_addr;
	input logic we_boot, bootloading;
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] PC_NEXT, I_DATA, Inst, PC, PC_INC;
	logic PC_EN, HLT, enable;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// PC Next Selection Mux
	assign PC_INC = PC + 4;
	assign PC_NEXT = PC_SRC ? (TARGET_ADDR) : (PC_INC);
	
	// PC Enable: When NOT observe a HALT Instruction
	assign PC_EN = ~(HLT | STALL | LWCP_STALL);
	
	// Program Counter
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			PC <= 'h0;
		end
		else if (PC_EN) begin
			PC <= PC_NEXT;
		end
	end
	
	// I-Mem Instantiation: 11-Bit Addr Width -> WORD ADDRESSABLE
	I_MEM i_mem(.clk(clk), .addr(PC[ADDRIW + 2 : 2]), .instr(I_DATA), 
	.wdata_data(wdata_data), .wdata_addr(wdata_addr), .we_boot(we_boot), .bootloading(bootloading));
	
	// Muxing of Instruction with NOP in event of a FLUSH
	assign Inst = FLUSH ? (NOP) : (I_DATA);
	
	// HALT DETECTION
	assign HLT = ((opcode_t'(Inst[6:0])) == ECALL_i);
	
	// Pipeline Flop Enable
	assign enable = ~(STALL | LWCP_STALL);
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Pipeline Registers //////////////////////
    ////////////////////////////////////////////////////////////
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			IF_ID_Inst <= NOP; // Default to NOP (ADDI x0, x0, 0)
			IF_ID_PC <= 'h0; // Defaut to PC of 0
			IF_ID_PC_INC <= 'h4; // PC Default + 4
			IF_ID_HLT <= 'h0;
		end
		else if (enable) begin
			IF_ID_Inst <= Inst;
			IF_ID_PC <= PC;
			IF_ID_PC_INC <= PC_INC;
			IF_ID_HLT <= HLT;
		end
	end
endmodule
`default_nettype wire