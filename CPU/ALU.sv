///////////////////////////////////////////////////////////////////////////////
// Program: ALU.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I ALU Top-Level
//
//  - Inputs:
//      A_in:    	Input Operand A
//      B_in:    	Input Operand B
//      ALU_OP:    	ALU Operation
//			- 0000 -> ADD / ADDI
//			- 0010 -> SUB
//			- 0011 -> SLT / SLTI
//			- 1011 -> SLTU / SLTIU
//			- 0100 -> XOR / XORI
//			- 0101 -> OR / ORI
//			- 0110 -> AND / ANDI
//			- 1100 -> SLL / SLLI
//			- 1101 -> SRL / SRLI
//			- 1111 -> SRA / SRAI
//      SHAMT:      Shift Amount [5:0]
//
//  - Outputs:
//      Shifter_Out:	Output Shifted Result
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module ALU (A_in, B_in, ALU_OP, SHAMT, ALU_OUT);
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wire [BITS - 1 : 0] A_in, B_in;
	input alu_t ALU_OP;
	input wire [4 : 0] SHAMT;
	output logic [BITS - 1 : 0] ALU_OUT;
	
	
	
	////////////////////////////////////////////////////////////
	////////////////// Intermediate Signals ////////////////////
	////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] ADDER_OUT, SHIFTER_OUT, LOGICAL_OUT,
			COMPARATOR_OUT, B_input;
	shift_t SHIFT_OP;
	logic LT, LTU, less_than;
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Operation //////////////////////
    ////////////////////////////////////////////////////////////
	
	// ADDER TOP
	assign B_input = B_in ^ {(BITS){ALU_OP[1]}}; // Inversion of B on Subtraction
	assign ADDER_OUT = A_in + B_input + ALU_OP[1];
	
	// SHIFTER TOP
	assign SHIFT_OP = shift_t'(ALU_OP[1:0]); // SHIFT Operation Select
	shifter SHIFTER(.Shifter_In(A_in), .SHAMT(SHAMT), .SHIFT_OP(SHIFT_OP),
						.Shifter_Out(SHIFTER_OUT));
	
	// LOGICAL UNIT TOP
	LOGICAL_TOP LOGICAL(.A(A_in), .B(B_in), .Sel(ALU_OP[1:0]), .Out(LOGICAL_OUT));
	
	// COMPARATOR TOP
	COMPARATOR_TOP COMPARATOR(.A(A_in), .B(B_in), .LT(LT), .LTU(LTU), .EQ());
	assign less_than = ALU_OP[3] ? (LTU) : (LT);
	
	// Generate Comparator Out from LT/LTU Flag
	assign COMPARATOR_OUT = {{(BITS - 1){1'b0}}, less_than};
	
	// Mux Operation output to ALU Out
	assign ALU_OUT = (&ALU_OP[3:2]) ? (SHIFTER_OUT) :
					 (~ALU_OP[3] & ALU_OP[2]) ? (LOGICAL_OUT) :
					 (~ALU_OP[2] & (&ALU_OP[1:0])) ? (COMPARATOR_OUT) :
					 (ADDER_OUT); // Default to ADDER OUT
endmodule
`default_nettype wire