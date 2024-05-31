///////////////////////////////////////////////////////////////////////////////
// Program: common_params.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Common Parameters Package used for global parameters and enumerations
//		in the RISC-V
///////////////////////////////////////////////////////////////////////////////

package common_params;
	// CPU Bitwidth
	localparam int BITS = 32;
	
	// Data & Instruction Memory Address Width
	localparam int ADDRW = 13;
	localparam int ADDRIW = 11;
	
	// Memory Bytes per Word
	localparam int BYTES_PER_WORD = 4;
	
	// Instruction NOP: (ADDI x0, x0, 0)
	localparam logic [BITS - 1 : 0] NOP = 'h0;
	
	// Shift Type Enumeration
	typedef enum logic [1:0] {LL = 2'b00, RL = 2'b01, RA = 2'b11} shift_t;
	
	// ALU Operation Enumeration
	typedef enum logic [3:0] {ADD = 4'b0000, SUB = 4'b0010, SLT = 4'b0011,
		SLTU = 4'b1011, XOR = 4'b0100, OR = 4'b0101, AND = 4'b0110,
		SLL = 4'b1100, SRL = 4'b1101, SRA = 4'b1111} alu_t;

	// Instruction Opcode Table Enumeration
	typedef enum logic [6:0] {LUI_i = 7'b0110111, AUIPC_i = 7'b0010111,
		JAL_i = 7'b1101111, JALR_i = 7'b1100111, BR_i = 7'b1100011,
		LOAD_i = 7'b0000011, STORE_i = 7'b0100011, ALUI_i = 7'b0010011,
		ALU_i = 7'b0110011, ECALL_i = 7'b1110011} opcode_t;
	
	// Memory Access Data Type
	typedef enum logic [2:0] {BYTE = 3'b000, HALFWORD = 3'b001, WORD = 3'b010,
		UBYTE = 3'b100, UHALFWORD = 3'b101, LWCP = 3'b111} mem_data_t;
		
	// Branch Condition Type
	typedef enum logic [2:0] {BEQ = 3'b000, BNE = 3'b001, BLT = 3'b100, BGE = 3'b101,
		BLTU = 3'b110, BGEU = 3'b111} branch_t;
		
	// EXECUTE Output Mux Select Type Enumeration
	typedef enum logic [1:0] {ALU_o = 2'b00, IMM_o = 2'b01, PC_INC_o = 2'b10} execute_mux_t;
	
	// Write Back Mux Select Type Enumeration
	typedef enum logic {EX_OUT_wbmux = 1'b0, DATA_MEM_wbmux = 1'b1} wb_mux_t;

	//Bootloader destination
	localparam int I_MEM = 3'b100;
	localparam int D_MEM = 3'b010;
	localparam int IMAGE_BUFFER = 3'b001;

	localparam int IB_DW = 3072;

	//Bootloader MEMORY DATA WIDTH PER BYTE
	localparam int IB_DW_PB = 384;
    localparam int I_D_MEM_DW_PB = 4;

	localparam int ADDR_WIDTH_PB = 2;
endpackage