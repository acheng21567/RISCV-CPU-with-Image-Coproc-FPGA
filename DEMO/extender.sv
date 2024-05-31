///////////////////////////////////////////////////////////////////////////////
// Program: extender.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Bit Extender for Sign & Zero Extension in the Data Memory Module
//
//  - Inputs:
//      data_in:    		Input Data for Extension
//      data_type:    		Data Type of Input Data
//								- BYTE, HALFWORD, WORD, UBYTE, UHALFWORD, LWCP
//
//  - Outputs:
//      data_out:			Output Extended Data
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module extender (data_in, data_type, data_out);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] data_in;
	input mem_data_t data_type;
	output logic [BITS - 1 : 0] data_out;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] sBYTE, uBYTE, sHALF, uHALF;
	
	localparam byte_boundary = BITS / BYTES_PER_WORD;
	localparam byte_remaining = BITS - byte_boundary;
	localparam half_boundary = BITS / 2;
	localparam half_remaining = BITS - half_boundary;
	
	
	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
	
	// Byte Sign Extension
	assign sBYTE = {{(byte_remaining){data_in[byte_boundary - 1]}},
						data_in[byte_boundary - 1 : 0]};
	
	// Byte Zero Extension
	assign uBYTE = {{(byte_remaining){1'b0}},
						data_in[byte_boundary - 1 : 0]};
	
	// Half Word Sign Extension
	assign sHALF = {{(half_remaining){data_in[half_boundary - 1]}},
						data_in[half_boundary - 1 : 0]};
	
	// Half Word Zero Extension
	assign uHALF = {{(half_remaining){1'b0}},
						data_in[half_boundary - 1 : 0]};
	
	// Output Selection Based on Memory Data Type
	always_comb begin
		case(data_type)
			BYTE : data_out = sBYTE;
			UBYTE : data_out = uBYTE;
			HALFWORD : data_out = sHALF;
			UHALFWORD : data_out = uHALF;
			default: data_out = data_in; // Default to Word Case (No Extension)
		endcase
	end
endmodule
`default_nettype wire