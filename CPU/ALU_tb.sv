///////////////////////////////////////////////////////////////////////////////
// Program: ALU_tb.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Testbench for RISC-V Base 32I ALU TOP (32-bit)
///////////////////////////////////////////////////////////////////////////////

module ALU_tb();
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Testbench Signals /////////////////////
    ////////////////////////////////////////////////////////////
	// DUT Output Signals
    logic [BITS - 1 : 0] ALU_OUT;
	
	// Stimulus & Checker Signals
    logic [BITS - 1 : 0] A_in, B_in, expected;
	logic [4 : 0] SHAMT;
	alu_t ALU_OP;
    int error;
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Module Instantiation ////////////////////
    ////////////////////////////////////////////////////////////
	ALU DUT(.A_in(A_in), .B_in(B_in), .ALU_OP(ALU_OP), .SHAMT(SHAMT),
			.ALU_OUT(ALU_OUT));
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Stimulus & Checking ////////////////////
    ////////////////////////////////////////////////////////////
	initial begin
	    error = 0; // Initially All tests Pass

        for (int i = 0; i < 1000; i++) begin
            // Generate Random Stimulus
            A_in = $random;
            B_in = $random;
            SHAMT = $random;
            ALU_OP = alu_t'($random % 16);
			#5; // Delay for Logic propagation
			
			// Behavioral Model
			case (ALU_OP)
				ADD : begin
					expected = A_in + B_in; #1;
				end
				SUB : begin
					expected = A_in - B_in; #1;
				end
				SLT : begin
					expected = {31'h0, ($signed(A_in) < $signed(B_in))}; #1;
				end
				SLTU : begin
					expected = {31'h0, ($unsigned(A_in) < $unsigned(B_in))}; #1;
				end
				XOR : begin
					expected = A_in ^ B_in; #1;
				end
				OR : begin
					expected = A_in | B_in; #1;
				end
				AND : begin
					expected = A_in & B_in; #1;
				end
				SLL : begin
					expected = A_in << SHAMT; #1;
				end
				SRL : begin
					expected = A_in >> SHAMT; #1;
				end
				SRA : begin
					expected = $signed(A_in) >>> SHAMT; #1;
				end
				default : begin // NOT VALID OPERATION
					expected = ALU_OUT; #1;
				end
			endcase
			
			// ALU Output Comparison
			if (ALU_OUT !== expected) begin
					$display("- ERROR on Test #%d on %s Instruction. ",
						i, ALU_OP.name(),
						"For Inputs A: 0x%h, B: 0x%h. ", A_in, B_in,
						"Expected: 0x%h, Returned: 0x%h.", expected, ALU_OUT);
					error = error + 1;
			end
		end
		
		// Report Simulation Error Count
        if (error == 0) begin
            $display("- All Test Cases Passed !");
        end
        else begin
            $display("- %d Errors During Simulation", error);
        end
	end
endmodule