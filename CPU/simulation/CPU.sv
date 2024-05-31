///////////////////////////////////////////////////////////////////////////////
// Program: CPU.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level CPU
//
//  - Inputs:
//      clk:    		Global Clock
//      rst_n:    		Global Active Low Reset
//      IO_RDATA:    	Read Data bus from Memory-Mapped I/O
//
//  - Outputs:
//      HLT:			Flag Signifying Processor Completion of Program
//      IO_WDATA:		Write Data bus to Memory-Mapped I/O
//      IO_ADDR:		Memory-Mapped I/O Address
//      IO_WEN:			Memory-Mapped I/O Write Enable
//      IO_RDEN:		Memory-Mapped I/O Read Enable
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module CPU (clk, rst_n, HLT, IO_WDATA, IO_RDATA, IO_ADDR, IO_WEN, IO_RDEN,
	wdata_data, wdata_addr, dst, bootloading);

	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] IO_RDATA;
	input logic clk, rst_n;
	output logic [BITS - 1 : 0] IO_WDATA, IO_ADDR;
	output logic HLT, IO_WEN, IO_RDEN;
	
	input logic [BITS - 1 : 0] wdata_data;
	input logic [ADDRW : 0] wdata_addr;
	input logic [2 : 0] dst;
	input logic bootloading;
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] ID_TARGET_ADDR, IF_ID_Inst, IF_ID_PC, IF_ID_PC_INC,
		WB_OUT, ID_EX_IMM32, ID_EX_SRA, ID_EX_SRB, EX_MEM_EXECUTE_OUT,
		MEM_WB_MEM_DATA_OUT, ID_EX_PC, ID_EX_PC_INC, EX_MEM_MEM_DATA_IN, 
		MEM_WB_EXECUTE_OUT, EX_MEM_PC, MEM_WB_PC;
		
	logic [$clog2(BITS) - 1 : 0] ID_EX_SHAMT, ID_EX_RD, EX_MEM_RD, MEM_WB_RD,
		ID_RS1, ID_RS2, ID_EX_RS1, ID_EX_RS2, EX_MEM_RS2;
	logic [1:0] FORWARD_EXECUTE_A, FORWARD_EXECUTE_B;
	logic ID_PC_SRC, ID_EX_MEM_WRITE, ID_EX_MEM_READ, ID_EX_ALU_A_SRC,
		ID_EX_ALU_B_SRC, IF_ID_HLT, ID_EX_REG_WRITE, EX_MEM_MEM_WRITE,
		EX_MEM_MEM_READ, EX_MEM_REG_WRITE, MEM_WB_REG_WRITE, ID_EX_HLT,
		EX_MEM_HLT, MEM_WB_HLT, ID_BRANCH, ID_JUMPR, FORWARD_MEMORY, 
		FORWARD_DECODE_A, FORWARD_DECODE_B, ID_MEM_WRITE, ID_REG_WRITE,
		STALL, FLUSH, ID_I_TYPE, IO_EN, D_MEM_WRITE,
		D_MEM_READ, LWCP_STALL;
		
	wb_mux_t ID_EX_WB_SRC_SEL, EX_MEM_WB_SRC_SEL, MEM_WB_WB_SRC_SEL;
	mem_data_t ID_EX_MEM_TYPE, EX_MEM_MEM_TYPE;
	alu_t ID_EX_ALU_OP;
	execute_mux_t ID_EX_EX_OUT_SEL;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// FETCH TOP
	FETCH_TOP IF(.clk(clk), .rst_n(rst_n), .TARGET_ADDR(ID_TARGET_ADDR),
		.PC_SRC(ID_PC_SRC), .IF_ID_Inst(IF_ID_Inst), .IF_ID_PC(IF_ID_PC), 
		.IF_ID_PC_INC(IF_ID_PC_INC), .IF_ID_HLT(IF_ID_HLT), .STALL(STALL),
		.FLUSH(FLUSH), .wdata_data(wdata_data), .wdata_addr(wdata_addr), .we_boot(dst[2]), 
		.bootloading(bootloading), .LWCP_STALL(LWCP_STALL));
	
	// HAZARD UNIT
	HAZARD_UNIT HU(.ID_EX_MEM_READ(ID_EX_MEM_READ), .ID_MEM_WRITE(ID_MEM_WRITE),
		.ID_REG_WRITE(ID_REG_WRITE), .ID_EX_RD(ID_EX_RD), .ID_RS1(ID_RS1),
		.ID_RS2(ID_RS2), .ID_BRANCH(ID_BRANCH), .ID_JUMPR(ID_JUMPR), 
		.ID_EX_REG_WRITE(ID_EX_REG_WRITE), .EX_MEM_MEM_READ(EX_MEM_MEM_READ),
		.EX_MEM_RD(EX_MEM_RD), .ID_PC_SRC(ID_PC_SRC), .STALL(STALL),
		.FLUSH(FLUSH), .ID_I_TYPE(ID_I_TYPE));
	
	// DECODE TOP
	DECODE_TOP ID(.clk(clk), .rst_n(rst_n), .IF_ID_Inst(IF_ID_Inst),
		.IF_ID_PC(IF_ID_PC), .WB_DATA(WB_OUT), .ID_PC_SRC(ID_PC_SRC),
		.ID_TARGET_ADDR(ID_TARGET_ADDR), .ID_EX_IMM32(ID_EX_IMM32),
		.ID_EX_WB_SRC_SEL(ID_EX_WB_SRC_SEL), .ID_EX_MEM_WRITE(ID_EX_MEM_WRITE),
		.ID_EX_MEM_READ(ID_EX_MEM_READ), .ID_EX_MEM_TYPE(ID_EX_MEM_TYPE),
		.ID_EX_EX_OUT_SEL(ID_EX_EX_OUT_SEL), .ID_EX_SHAMT(ID_EX_SHAMT), 
		.ID_EX_ALU_OP(ID_EX_ALU_OP), .ID_EX_ALU_A_SRC(ID_EX_ALU_A_SRC),
		.ID_EX_ALU_B_SRC(ID_EX_ALU_B_SRC), .ID_EX_SRA(ID_EX_SRA), .ID_EX_SRB(ID_EX_SRB),
		.IF_ID_PC_INC(IF_ID_PC_INC), .IF_ID_HLT(IF_ID_HLT), .ID_EX_RD(ID_EX_RD), 
		.ID_EX_REG_WRITE(ID_EX_REG_WRITE), .ID_EX_PC(ID_EX_PC), .ID_EX_PC_INC(ID_EX_PC_INC),
		.ID_EX_HLT(ID_EX_HLT), .MEM_WB_RD(MEM_WB_RD), .MEM_WB_REG_WRITE(MEM_WB_REG_WRITE),
		.ID_RS1(ID_RS1), .ID_RS2(ID_RS2), .ID_BRANCH(ID_BRANCH), .ID_JUMPR(ID_JUMPR),
		.ID_EX_RS1(ID_EX_RS1), .ID_EX_RS2(ID_EX_RS2), .FORWARD_DECODE_A(FORWARD_DECODE_A),
		.FORWARD_DECODE_B(FORWARD_DECODE_B), .EX_MEM_EXECUTE_OUT(EX_MEM_EXECUTE_OUT), 
		.ID_MEM_WRITE(ID_MEM_WRITE), .ID_REG_WRITE(ID_REG_WRITE), .STALL(STALL),
		.ID_I_TYPE(ID_I_TYPE), .LWCP_STALL(LWCP_STALL));
	
	// FORWARDING UNIT
	FORWARDING_UNIT FU(.ID_RS1(ID_RS1), .ID_RS2(ID_RS2), .ID_BRANCH(ID_BRANCH),
		.ID_JUMPR(ID_JUMPR), .ID_EX_RS1(ID_EX_RS1), .ID_EX_RS2(ID_EX_RS2),
		.ID_EX_REG_WRITE(ID_EX_REG_WRITE), .ID_EX_MEM_WRITE(ID_EX_MEM_WRITE),
		.EX_MEM_RS2(EX_MEM_RS2), .EX_MEM_REG_WRITE(EX_MEM_REG_WRITE),
		.EX_MEM_MEM_WRITE(EX_MEM_MEM_WRITE), .EX_MEM_RD(EX_MEM_RD),
		.MEM_WB_RD(MEM_WB_RD), .MEM_WB_REG_WRITE(MEM_WB_REG_WRITE),
		.FORWARD_EXECUTE_A(FORWARD_EXECUTE_A), .FORWARD_EXECUTE_B(FORWARD_EXECUTE_B),
		.FORWARD_MEMORY(FORWARD_MEMORY), .FORWARD_DECODE_A(FORWARD_DECODE_A),
		.FORWARD_DECODE_B(FORWARD_DECODE_B));
	
	// EXECUTE TOP
	EXECUTE_TOP EX(.ID_EX_SHAMT(ID_EX_SHAMT), .ID_EX_ALU_OP(ID_EX_ALU_OP), 
		.ID_EX_ALU_A_SRC(ID_EX_ALU_A_SRC), .ID_EX_ALU_B_SRC(ID_EX_ALU_B_SRC), 
		.ID_EX_IMM32(ID_EX_IMM32), .ID_EX_SRA(ID_EX_SRA), .ID_EX_SRB(ID_EX_SRB),
		.ID_EX_PC(ID_EX_PC), .EX_MEM_MEM_TYPE(EX_MEM_MEM_TYPE), .EX_MEM_RD(EX_MEM_RD),
		.ID_EX_EX_OUT_SEL(ID_EX_EX_OUT_SEL), .EX_MEM_EXECUTE_OUT(EX_MEM_EXECUTE_OUT),
		.EX_MEM_MEM_DATA_IN(EX_MEM_MEM_DATA_IN), .EX_MEM_MEM_READ(EX_MEM_MEM_READ),
		.ID_EX_PC_INC(ID_EX_PC_INC), .ID_EX_WB_SRC_SEL(ID_EX_WB_SRC_SEL),
		.ID_EX_MEM_WRITE(ID_EX_MEM_WRITE), .EX_MEM_REG_WRITE(EX_MEM_REG_WRITE),
		.ID_EX_MEM_READ(ID_EX_MEM_READ), .ID_EX_MEM_TYPE(ID_EX_MEM_TYPE), 
		.ID_EX_RD(ID_EX_RD), .ID_EX_REG_WRITE(ID_EX_REG_WRITE),
		.EX_MEM_MEM_WRITE(EX_MEM_MEM_WRITE), .clk(clk), .rst_n(rst_n),
		.EX_MEM_WB_SRC_SEL(EX_MEM_WB_SRC_SEL), .ID_EX_HLT(ID_EX_HLT), 
		.EX_MEM_HLT(EX_MEM_HLT), .WB_DATA(WB_OUT), .EX_MEM_PC(EX_MEM_PC),
		.ID_EX_RS2(ID_EX_RS2), .EX_MEM_RS2(EX_MEM_RS2), .LWCP_STALL(LWCP_STALL),
		.FORWARD_EXECUTE_A(FORWARD_EXECUTE_A), .FORWARD_EXECUTE_B(FORWARD_EXECUTE_B));
	
	// MEMORY TOP
	MEMORY_TOP MEM(.clk(clk), .rst_n(rst_n), .EX_MEM_MEM_TYPE(EX_MEM_MEM_TYPE),
		.EX_MEM_MEM_WRITE(D_MEM_WRITE), .EX_MEM_MEM_READ(D_MEM_READ),
		.EX_MEM_EXECUTE_OUT(EX_MEM_EXECUTE_OUT), .EX_MEM_MEM_DATA_IN(EX_MEM_MEM_DATA_IN),
		.EX_MEM_WB_SRC_SEL(EX_MEM_WB_SRC_SEL), .EX_MEM_RD(EX_MEM_RD), .MEM_WB_RD(MEM_WB_RD),
		.EX_MEM_REG_WRITE(EX_MEM_REG_WRITE), .MEM_WB_MEM_DATA_OUT(MEM_WB_MEM_DATA_OUT),
		.MEM_WB_EXECUTE_OUT(MEM_WB_EXECUTE_OUT), .MEM_WB_WB_SRC_SEL(MEM_WB_WB_SRC_SEL), 
		.MEM_WB_REG_WRITE(MEM_WB_REG_WRITE), .EX_MEM_HLT(EX_MEM_HLT), .EX_MEM_PC(EX_MEM_PC),
		.MEM_WB_HLT(HLT), .FORWARD_MEMORY(FORWARD_MEMORY), .WB_DATA(WB_OUT),
		.MEM_WB_PC(MEM_WB_PC), .IO_RDATA(IO_RDATA), .IO_RDEN(IO_RDEN), 
		.wdata_data(wdata_data), .wdata_addr(wdata_addr[ADDRW - 1 : 0]), .we_boot(dst[1]), 
		.bootloading(bootloading), .LWCP_STALL(LWCP_STALL));
	
	// LWCP Detection: LWCP Instruction, Valid Read from I/O Region, & !DONE
	assign LWCP_STALL = (EX_MEM_MEM_TYPE == LWCP) & (~IO_RDATA[1]) & (IO_RDEN);
	
	// I/O INTERFACE
	assign IO_WDATA = FORWARD_MEMORY ? WB_OUT : EX_MEM_MEM_DATA_IN;
	assign IO_ADDR = EX_MEM_EXECUTE_OUT;
	assign IO_EN = |(EX_MEM_EXECUTE_OUT[BITS - 1 : ADDRW]);
	assign IO_WEN = IO_EN & EX_MEM_MEM_WRITE;
	assign IO_RDEN = IO_EN & EX_MEM_MEM_READ;
	assign D_MEM_WRITE = (~IO_EN) & EX_MEM_MEM_WRITE;
	assign D_MEM_READ = (~IO_EN) & EX_MEM_MEM_READ;

	// WRITE BACK TOP
	WB_TOP WB(.MEM_WB_WB_SRC_SEL(MEM_WB_WB_SRC_SEL), .MEM_WB_MEM_DATA_OUT(MEM_WB_MEM_DATA_OUT),
		.MEM_WB_EXECUTE_OUT(MEM_WB_EXECUTE_OUT), .WB_OUT(WB_OUT));
endmodule
`default_nettype wire