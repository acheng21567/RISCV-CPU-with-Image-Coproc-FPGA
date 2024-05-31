///////////////////////////////////////////////////////////////////////////////
// Program: MEMORY_TOP.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level MEMORY Pipeline Stage
//
//  - Inputs:
//      clk:    				Global Clock 
//      rst_n:    				Global Active Low Reset 
//      EX_MEM_MEM_TYPE:    	Data Type of Currently Accessed Memory Value
//      EX_MEM_MEM_WRITE:    	Memory Write Enable
//      EX_MEM_MEM_READ:    	Memory Read Enable
//      EX_MEM_EXECUTE_OUT:    	Data Memory Byte-Address
//      EX_MEM_MEM_DATA_IN:    	Memory Write Data Input
//      EX_MEM_WB_SRC_SEL:    	Pass Through WB_SRC_SEL from Execute Stage
//      EX_MEM_RD:   		 	Pass Through Reg File Dest ADDR from Execute Stage
//      EX_MEM_REG_WRITE:    	Pass Through Reg File WEN from Execute Stage
//      EX_MEM_HLT:   		 	Pass Through Halt Flag
//      EX_MEM_PC:   	Pass Through Program Counter
//		FORWARD_MEMORY:			Forwarding Mux Select
//		WB_DATA:				Forwarded Output from Write Back Stage
//		IO_RDATA:				Memory-Mapped I/O Read Data
//		IO_RDEN:				Memory-Mapped I/O Read Enable
//		LWCP_STALL:				Dedicated LWCP Instruction Global STALL
//
//  - Outputs:
//      MEM_WB_MEM_DATA_OUT:	Pipelined Output Data from D-MEM
//      MEM_WB_EXECUTE_OUT:		Pipelined Execute Stage Output
//      MEM_WB_WB_SRC_SEL:		Pipelined WB_SRC_SEL
//      MEM_WB_RD:				Pipelined Reg File Dest ADDR
//      MEM_WB_REG_WRITE:		Pipelined Reg File WEN
//      MEM_WB_HLT:				Pipelined Halt Flag
//      MEM_WB_PC:				Pipelined Program Counter
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module MEMORY_TOP (clk, rst_n, EX_MEM_MEM_TYPE, EX_MEM_MEM_WRITE,
		EX_MEM_MEM_READ, EX_MEM_EXECUTE_OUT, EX_MEM_MEM_DATA_IN,
		MEM_WB_MEM_DATA_OUT, MEM_WB_EXECUTE_OUT, EX_MEM_WB_SRC_SEL,
		MEM_WB_WB_SRC_SEL, EX_MEM_RD, MEM_WB_RD, EX_MEM_REG_WRITE,
		MEM_WB_REG_WRITE, EX_MEM_HLT, MEM_WB_HLT, FORWARD_MEMORY,
		WB_DATA, EX_MEM_PC, MEM_WB_PC, IO_RDATA, IO_RDEN,
		wdata_data, wdata_addr, we_boot, bootloading, LWCP_STALL);
		
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] EX_MEM_EXECUTE_OUT, EX_MEM_MEM_DATA_IN,
		WB_DATA, EX_MEM_PC, IO_RDATA;
	input logic [4:0] EX_MEM_RD;
	input logic clk, EX_MEM_MEM_READ, EX_MEM_MEM_WRITE, EX_MEM_REG_WRITE,
		EX_MEM_HLT, rst_n, FORWARD_MEMORY, IO_RDEN, LWCP_STALL;
		
	input mem_data_t EX_MEM_MEM_TYPE;
	input wb_mux_t EX_MEM_WB_SRC_SEL;
	output logic [BITS - 1 : 0] MEM_WB_MEM_DATA_OUT, MEM_WB_EXECUTE_OUT,
		MEM_WB_PC;
		
	output logic [4:0] MEM_WB_RD;
	output logic MEM_WB_HLT, MEM_WB_REG_WRITE;
	output wb_mux_t MEM_WB_WB_SRC_SEL;
	
	input logic [BITS - 1 : 0] wdata_data;
	input logic [ADDRW - 1 : 0] wdata_addr;
	input logic we_boot, bootloading;
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] MEM_DATA_OUT, MEM_DATA_IN, DATA_OUT;
	logic [ADDRW - 1 : 0] MEM_ADDR;
	logic MEM_WRITE;
	mem_data_t MEM_TYPE;

	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

	// Data Forwarding Mux: Pipelined Value (0), Forwarded Value (1)
	assign MEM_DATA_IN = we_boot ? wdata_data : FORWARD_MEMORY ? (WB_DATA) : (EX_MEM_MEM_DATA_IN);
	
	//Bootload check
	assign MEM_WRITE = bootloading ? we_boot : EX_MEM_MEM_WRITE;
	assign MEM_ADDR = we_boot ? wdata_addr : EX_MEM_EXECUTE_OUT[ADDRW-1:0];
	assign MEM_TYPE = bootloading ? WORD : EX_MEM_MEM_TYPE;

	// Data Memory Instantiation: 13 Lower Bits of Address for (32KB)
	D_MEM d_mem(.clk(clk), .MEM_DATA_IN(MEM_DATA_IN),
				.MEM_DATA_TYPE(MEM_TYPE), .MEM_READ(EX_MEM_MEM_READ),
				.MEM_ADDR(MEM_ADDR), .MEM_WRITE(MEM_WRITE),
				.MEM_DATA_OUT(MEM_DATA_OUT));
				
	// Selection of I/O Read Data on Memory-Map Read
	assign DATA_OUT = (IO_RDEN) ? (IO_RDATA) : (MEM_DATA_OUT);
				
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Pipeline Registers //////////////////////
    ////////////////////////////////////////////////////////////
	always_ff @(posedge clk) begin
		if (~rst_n) begin
			MEM_WB_EXECUTE_OUT <= 'h0;
			MEM_WB_MEM_DATA_OUT <= 'h0;
			MEM_WB_WB_SRC_SEL <= wb_mux_t'('h0);
			MEM_WB_RD <= 'h0;
			MEM_WB_REG_WRITE <= 'h0;
			MEM_WB_HLT <= 'h0;
			MEM_WB_PC <= 'h0;
		end
		else if (~LWCP_STALL) begin
			MEM_WB_EXECUTE_OUT <= EX_MEM_EXECUTE_OUT;
			MEM_WB_MEM_DATA_OUT <= DATA_OUT;
			MEM_WB_WB_SRC_SEL <= EX_MEM_WB_SRC_SEL;
			MEM_WB_RD <= EX_MEM_RD;
			MEM_WB_REG_WRITE <= EX_MEM_REG_WRITE;
			MEM_WB_HLT <= EX_MEM_HLT;
			MEM_WB_PC <= EX_MEM_PC;	
		end
	end
	
endmodule
`default_nettype wire