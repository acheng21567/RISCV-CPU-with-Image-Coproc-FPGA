///////////////////////////////////////////////////////////////////////////////
// Program: D_MEM.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Top Level Data Memory for Single Cycle RAM Access
//	- NOTE: ASSUMING ONLY 4 BYTES PER WORD
//
//  - Inputs:
//      clk:    			Global Clock 
//      MEM_DATA_IN:    	Data Memory Write Input
//      MEM_WRITE:    		Write Enable
//      MEM_READ:    		Read Enable
//      MEM_ADDR:    		Memory Access Address
//      MEM_DATA_TYPE: 		Memory Access Type
//								- BYTE, HALFWORD, WORD, UBYTE, UHALFWORD, LWCP
//
//  - Outputs:
//      MEM_DATA_OUT:		Output Data Accessed from Memory
///////////////////////////////////////////////////////////////////////////////

`default_nettype none
module D_MEM (clk, MEM_DATA_IN, MEM_WRITE, MEM_READ, MEM_ADDR,
		MEM_DATA_TYPE, MEM_DATA_OUT);
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input logic [BITS - 1 : 0] MEM_DATA_IN;
	input logic [ADDRW - 1 : 0] MEM_ADDR;
	input logic clk, MEM_WRITE, MEM_READ;
	input mem_data_t MEM_DATA_TYPE;
	output logic [BITS - 1 : 0] MEM_DATA_OUT;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	
	logic [BITS - 1 : 0] data_out, shifter_in, shifter_out, extender_out;
	logic [ADDRW - 1 : 0] address;
	logic [(BITS / 2) - 1 : 0] halfword_out;
	logic [BYTES_PER_WORD - 1 : 0] read_enable, write_enable, enable_mask;
	logic [(BITS / BYTES_PER_WORD) - 1 : 0] byte_out;
	logic [(ADDRW - $clog2(BYTES_PER_WORD)) - 1 : 0] word_addr; // Word of Current Address
	logic [$clog2(BYTES_PER_WORD) - 1 : 0] byte_addr; // Byte of Current Address
	logic [$clog2(BITS) - 1 : 0] SHAMT;
	shift_t SHIFT_OP;
	
	
	
	////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
	
	// Memory Bank Input Enable Decoding
	always_comb begin
		case(MEM_DATA_TYPE) 
			HALFWORD, UHALFWORD : begin // Halfword Case: Enable Specific Half
				case(byte_addr[1])
					0 : enable_mask = {{(BYTES_PER_WORD / 2){1'b0}}, {(BYTES_PER_WORD / 2){1'b1}}};
					1 : enable_mask = {{(BYTES_PER_WORD / 2){1'b1}}, {(BYTES_PER_WORD / 2){1'b0}}};
				endcase
			end
			
			BYTE, UBYTE : begin // Byte Case: Enable Specific Byte
				enable_mask = 'b0001 << byte_addr;
			end
			
			default : enable_mask = {BYTES_PER_WORD{1'b1}}; // Word Case: Enable Entire Word
		endcase
	end

	// Truncation of Memory Address Based on Memory Data Type
	always_comb begin
		case(MEM_DATA_TYPE) 
			HALFWORD, UHALFWORD : begin // Halfword Case
				address = MEM_ADDR;
			end
			
			BYTE, UBYTE : begin // Byte Case
				address = {MEM_ADDR[ADDRW-1:1], 2'b1};
			end
			
			default : address = {MEM_ADDR[ADDRW-1:2], 2'b0}; // Word Case
		endcase
	end


	// Read & Write Enables
	assign read_enable = enable_mask & ({(BYTES_PER_WORD){MEM_READ}});
	assign write_enable = enable_mask & ({(BYTES_PER_WORD){MEM_WRITE}});
	
	// Parameterizable Memory Banks: (Each Addr Corresponds to a single WORD)
	DATA_BANK #((BITS / BYTES_PER_WORD), ADDRW - $clog2(BYTES_PER_WORD)) BANK3
		(.clk(clk), .addr(address[ADDRW - 1 : $clog2(BYTES_PER_WORD)]), .rden(read_enable[3]),
		.wen(write_enable[3]), .Data_In(shifter_out[31:24]), .Data_Out(data_out[31:24]));
	DATA_BANK #((BITS / BYTES_PER_WORD), ADDRW - $clog2(BYTES_PER_WORD)) BANK2
		(.clk(clk), .addr(address[ADDRW - 1 : $clog2(BYTES_PER_WORD)]), .rden(read_enable[2]),
		.wen(write_enable[2]), .Data_In(shifter_out[23:16]), .Data_Out(data_out[23:16]));
	DATA_BANK #((BITS / BYTES_PER_WORD), ADDRW - $clog2(BYTES_PER_WORD)) BANK1
		(.clk(clk), .addr(address[ADDRW - 1 : $clog2(BYTES_PER_WORD)]), .rden(read_enable[1]),
		.wen(write_enable[1]), .Data_In(shifter_out[15:8]), .Data_Out(data_out[15:8]));
	DATA_BANK #((BITS / BYTES_PER_WORD), ADDRW - $clog2(BYTES_PER_WORD)) BANK0
		(.clk(clk), .addr(address[ADDRW - 1 : $clog2(BYTES_PER_WORD)]), .rden(read_enable[0]),
		.wen(write_enable[0]), .Data_In(shifter_out[7:0]), .Data_Out(data_out[7:0]));
	
	// Data BIT Shift Amount From Byte (MULTIPLY BY 8 -> SHIFT LEFT 3)
	assign SHAMT = byte_addr << (3);
	
	// Barrel Shifter Instantiation for SLL(00) (WRITES) or SRL(01) (READS) Shift; NO SRA
	assign shifter_in = (MEM_READ) ? (data_out) : (MEM_DATA_IN); // Selection of Shifter Data Based on READ / WRITE
	
	assign SHIFT_OP = shift_t'({1'b0, MEM_READ});
	
	shifter SHIFTER(.Shifter_In(shifter_in), .SHAMT(SHAMT), .SHIFT_OP(SHIFT_OP),
					.Shifter_Out(shifter_out));
					
	// Output Extender for Byte / Halfword Reads After Shift Down
	extender EXT(.data_in(shifter_out), .data_type(MEM_DATA_TYPE),
					.data_out(extender_out));
	
	// Bank Address -> Word Address of Input Mem Addr
	assign word_addr = address[ADDRW - 1 : $clog2(BYTES_PER_WORD)];
	
	// Byte Address -> Byte Being Accessed
	assign byte_addr = address[$clog2(BYTES_PER_WORD) - 1 : 0];
	
	// Disable Memory Output if MEM_READ not Enabled
	assign MEM_DATA_OUT = (MEM_READ) ? (extender_out) : ('h0);
endmodule
`default_nettype wire