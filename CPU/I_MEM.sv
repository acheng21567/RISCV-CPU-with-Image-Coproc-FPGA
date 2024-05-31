///////////////////////////////////////////////////////////////////////////////
// Program: I_MEM.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Top Level Instruction Memory for Single Cycle RAM Access
//
//  - Inputs:
//      clk:    			Global Clock 
//      addr:    			Read Address
//
//  - Outputs:
//      instr:				Output Instruction Accessed from Memory
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module I_MEM (clk, addr, instr, wdata_data, wdata_addr, we_boot, bootloading);
	// Import Common Parameters Package
	import common_params::*;
	
	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input logic [ADDRIW - 1 : 0] addr;
	input logic clk;
	output logic [BITS - 1 : 0] instr;

	input logic [BITS - 1 : 0] wdata_data;
	input logic [ADDRIW - 1 : 0] wdata_addr;
	input logic we_boot, bootloading;

	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] instr_mem[0 : (2**ADDRIW) - 1]; // Parameterizable Memory



	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
	
	// Synchronous Read of I-Mem
 	always @(negedge clk) begin
		if(~bootloading)
			instr <= instr_mem[addr];
	end

	//bootloading
	always @(negedge clk) begin
		if(we_boot)
			instr_mem[wdata_addr] <= wdata_data;
	end
endmodule
`default_nettype wire