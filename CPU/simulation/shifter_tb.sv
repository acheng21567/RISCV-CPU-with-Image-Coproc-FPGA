///////////////////////////////////////////////////////////////////////////////
// Program: shifter_tb.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Testbench for a General Purpose Barrel Shifter (32-bit)
///////////////////////////////////////////////////////////////////////////////

module shifter_tb();
	// Import Common Parameters Package
	import common_params::*;

	////////////////////////////////////////////////////////////
    //////////////////// Testbench Signals /////////////////////
    ////////////////////////////////////////////////////////////
	// DUT Output Signals
    logic [BITS - 1 : 0] DATA_OUT;
	
	// Stimulus & Checker Signals
    logic [BITS - 1 : 0] DATA_IN, expected;
    logic [4 : 0] SHAMT;
    shift_t OPSEL;
    int error;
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Module Instantiation ////////////////////
    ////////////////////////////////////////////////////////////
	shifter DUT(.Shifter_In(DATA_IN), .SHAMT(SHAMT), .SHIFT_OP(OPSEL),
				.Shifter_Out(DATA_OUT));
				
				
				
	////////////////////////////////////////////////////////////
    /////////////////// Stimulus & Checking ////////////////////
    ////////////////////////////////////////////////////////////
	initial begin
	    error = 0; // Initially All tests Pass

        for (int i = 0; i < 100; i++) begin
            // Generate Random Stimulus
            DATA_IN = $random;
            SHAMT = $random;
            OPSEL = shift_t'($random % 4);
			#5; // Delay for Logic propagation
			
			// Compare Shifter Output with Expected
			case(OPSEL)
				(LL) :  begin // SLL
					expected = DATA_IN << SHAMT; #1;
				end
				
				(RL) :  begin // SRL
					expected = DATA_IN >> SHAMT; #1;
				end
				
				(RA) :  begin // SRA
					expected = $signed(DATA_IN) >>> SHAMT; #1;
				end
			endcase
			
			if (OPSEL !== 2'b10) begin
				if (DATA_OUT !== expected) begin
					$display("Error on Test %d. Expected %h for Input %h, SHAMT %d, OPSEL %h ",
						i, expected, DATA_IN, SHAMT, OPSEL, "Returned %h", DATA_OUT);
					error = error + 1;
				end
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