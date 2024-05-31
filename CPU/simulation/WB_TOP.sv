///////////////////////////////////////////////////////////////////////////////
// Program: WB_TOP.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level WRITE BACK Pipeline Stage
//
//  - Inputs:
//      MEM_WB_WB_SRC_SEL:    	Output Source Selection for Data to Register File
//      MEM_WB_MEM_DATA_OUT:    Memory Data Output from LOAD Instructions
//      MEM_WB_EXECUTE_OUT:    	Execute Stage Output from ALU Operations
//
//  - Outputs:
//      WB_OUT:				Selected output to Register File
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module WB_TOP (MEM_WB_WB_SRC_SEL, MEM_WB_MEM_DATA_OUT, MEM_WB_EXECUTE_OUT, WB_OUT);

	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
	//////////////////// Module Port List //////////////////////
	////////////////////////////////////////////////////////////
	input wb_mux_t MEM_WB_WB_SRC_SEL;
	input logic [BITS - 1 : 0] MEM_WB_MEM_DATA_OUT, MEM_WB_EXECUTE_OUT;
	output logic [BITS - 1 : 0] WB_OUT;
	
	
	
	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
	assign WB_OUT = (MEM_WB_WB_SRC_SEL == DATA_MEM_wbmux) ? (MEM_WB_MEM_DATA_OUT) :
						(MEM_WB_EXECUTE_OUT);
endmodule
`default_nettype wire