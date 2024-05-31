///////////////////////////////////////////////////////////////////////////////
// Program: D_MEM_tb.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - Test Bench for the RISC-V Data Memory Module
///////////////////////////////////////////////////////////////////////////////

module D_MEM_tb ();
	// Import Common Parameters Package
	import common_params::*;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Testbench Signals /////////////////////
    ////////////////////////////////////////////////////////////
	logic [BITS - 1 : 0] MEM_DATA_IN, MEM_DATA_OUT;
	logic [ADDRW - 1 : 0] MEM_ADDR;
	mem_data_t MEM_DATA_TYPE;
	logic clk, MEM_WRITE, MEM_READ;
	int error;
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Module Instantiation ////////////////////
    ////////////////////////////////////////////////////////////
	D_MEM DUT(.clk(clk), .MEM_DATA_IN(MEM_DATA_IN), .MEM_WRITE(MEM_WRITE),
		.MEM_READ(MEM_READ), .MEM_ADDR(MEM_ADDR),
		.MEM_DATA_TYPE(MEM_DATA_TYPE), .MEM_DATA_OUT(MEM_DATA_OUT));
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Clock Generation //////////////////////
    ////////////////////////////////////////////////////////////
	always #5 clk = ~clk;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Stimulus & Checking ////////////////////
    ////////////////////////////////////////////////////////////
	initial begin
		clk = 0;
		MEM_WRITE = 0;
		MEM_READ = 0;
		MEM_ADDR = 0;
		MEM_DATA_IN = 0;
		MEM_DATA_TYPE = WORD;
		repeat(5)@(posedge clk);
		
		// Word Access Test
		word_access_test(1);
		
		// UHalfword Access Test
		uhalfword_access_test(2);
		
		// Halfword Access Test
		halfword_access_test(3);
		
		// UByte Access Test
		ubyte_access_test(4);
		
		// UByte Access Test
		byte_access_test(5);
		
		// Report Simulation Error Count
        if (error == 0) begin
            $display("- All Test Cases Passed !");
        end
        else begin
            $display("- %d Errors During Simulation", error);
        end
		$stop();
	end
	
	
	
	////////////////////////////////////////////////////////////
    ////////////////// Behavioral Functions ////////////////////
    ////////////////////////////////////////////////////////////
	
	//////////////////////////////////////////////////
	// Verification of Read & Write of Entire WORDS //
	//////////////////////////////////////////////////
	task word_access_test;
		input int test_num;
		
		// Initialize Configuration
		MEM_DATA_TYPE = WORD;
		
		// Perform Burst Write
		burst_write_word();
		
		// Perform Burst Read & Check Outputs
		repeat(5)@(posedge clk);
		burst_read_word(test_num);
		
		@(posedge clk);
	endtask
	
	
	//////////////////////////////////////////////////
	//     Iterative Write of Words to Memory       //
	//////////////////////////////////////////////////
	task burst_write_word;
		// Enable Memory for Write of WORD Type
		MEM_WRITE = 1;
		@(posedge clk);
		
		// Burst Write Words into Memory
		for (int i = 0; i < 400; i = i + 4) begin
			MEM_ADDR = i;
			MEM_DATA_IN = i;
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_WRITE = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//      Iterative Read of Words to Memory       //
	//////////////////////////////////////////////////
	task burst_read_word;
		input int test_num;
		logic [BITS - 1 : 0] expected;
	
		// Enable Memory for Read of WORD Type
		MEM_READ = 1;
		
		// Burst Read Words from Memory
		for (int i = 0; i < 400; i = i + 4) begin
			MEM_ADDR = i; 
			expected = i; #1;
			
			// Check for Valid Data Out
			if (MEM_DATA_OUT !== expected) begin
				$display("- ERROR on Test #%d, Read %d: Expected 0x%h from Address 0x%h, Returned 0x%h",
					test_num, i, expected, i, MEM_DATA_OUT);
				error = error + 1;
			end
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_READ = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//   Verification of Read & Write of uHalfwords //
	//////////////////////////////////////////////////
	task uhalfword_access_test;
		input int test_num;
		
		// Initialize Configuration
		MEM_DATA_TYPE = UHALFWORD;
		
		// Perform Burst Write
		burst_write_halfword();
		
		// Perform Burst Read & Check Outputs
		repeat(5)@(posedge clk);
		burst_read_uhalfword(test_num);
		
		@(posedge clk);
	endtask
	
	
	//////////////////////////////////////////////////
	//   Verification of Read & Write of Halfwords  //
	//////////////////////////////////////////////////
	task halfword_access_test;
		input int test_num;
		
		// Initialize Configuration
		MEM_DATA_TYPE = HALFWORD;
		
		// Perform Burst Write
		burst_write_halfword();
		
		// Perform Burst Read & Check Outputs
		repeat(5)@(posedge clk);
		burst_read_halfword(test_num);
		
		@(posedge clk);
	endtask
	
	
	//////////////////////////////////////////////////
	//     Verification of Read & Write of UBytes   //
	//////////////////////////////////////////////////
	task byte_access_test;
		input int test_num;
		
		// Initialize Configuration
		MEM_DATA_TYPE = BYTE;
		
		// Perform Burst Write
		burst_write_byte();
		
		// Perform Burst Read & Check Outputs
		repeat(5)@(posedge clk);
		burst_read_byte(test_num);
		
		@(posedge clk);
	endtask
	
	
	//////////////////////////////////////////////////
	//     Verification of Read & Write of Bytes    //
	//////////////////////////////////////////////////
	task ubyte_access_test;
		input int test_num;
		
		// Initialize Configuration
		MEM_DATA_TYPE = UBYTE;
		
		// Perform Burst Write
		burst_write_byte();
		
		// Perform Burst Read & Check Outputs
		repeat(5)@(posedge clk);
		burst_read_ubyte(test_num);
		
		@(posedge clk);
	endtask
	
	
	//////////////////////////////////////////////////
	//      Iterative Write of Bytes to Memory      //
	//////////////////////////////////////////////////
	task burst_write_byte;
		// Enable Memory for Write of Byte Type
		MEM_WRITE = 1;
		@(posedge clk);
		
		// Burst Write Words into Memory
		for (int i = 0; i < 100; i = i + 1) begin
			MEM_ADDR = i;
			MEM_DATA_IN = i;
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_WRITE = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//      Iterative Read of Bytes to Memory       //
	//////////////////////////////////////////////////
	task burst_read_byte;
		input int test_num;
		logic [BITS - 1 : 0] expected;
		
		// Enable Memory for Read
		MEM_READ = 1;
		
		// Burst Read Words from Memory
		for (int i = 0; i < 100; i = i + 1) begin
			MEM_ADDR = i; 
			expected = {{24{i[7]}}, i[7:0]}; #1;
			
			// Check for Valid Data Out
			if (MEM_DATA_OUT !== expected) begin
				$display("- ERROR on Test #%d, Read %d: Expected 0x%h from Address 0x%h, Returned 0x%h",
					test_num, i, i, expected, MEM_DATA_OUT);
				error = error + 1;
			end
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_READ = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//      Iterative Read of UBytes to Memory      //
	//////////////////////////////////////////////////
	task burst_read_ubyte;
		input int test_num;
		logic [BITS - 1 : 0] expected;
		
		// Enable Memory for Read
		MEM_READ = 1;
		
		// Burst Read Words from Memory
		for (int i = 0; i < 100; i = i + 1) begin
			MEM_ADDR = i; 
			expected = i; #1;
			
			// Check for Valid Data Out
			if (MEM_DATA_OUT !== expected) begin
				$display("- ERROR on Test #%d, Read %d: Expected 0x%h from Address 0x%h, Returned 0x%h",
					test_num, i, i, expected, MEM_DATA_OUT);
				error = error + 1;
			end
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_READ = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//    Iterative Write of Halfwords to Memory    //
	//////////////////////////////////////////////////
	task burst_write_halfword;
		// Enable Memory for Write of Halfword Type
		MEM_WRITE = 1;
		@(posedge clk);
		
		// Burst Write Halfword into Memory
		for (int i = 0; i < 200; i = i + 2) begin
			MEM_ADDR = i;
			MEM_DATA_IN = i + 16'h8000;
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_WRITE = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//     Iterative Read of UHalfwords to Memory   //
	//////////////////////////////////////////////////
	task burst_read_uhalfword;
		input int test_num;
		logic [BITS - 1 : 0] expected;
		
		// Enable Memory for Read
		MEM_READ = 1;
		
		// Burst Read Words from Memory
		for (int i = 0; i < 200; i = i + 2) begin
			MEM_ADDR = i; 
			expected = (i + 16'h8000); #1;
			
			// Check for Valid Data Out
			if (MEM_DATA_OUT !== expected) begin
				$display("- ERROR on Test #%d, Read %d: Expected 0x%h from Address 0x%h, Returned 0x%h",
					test_num, i, i, expected, MEM_DATA_OUT);
				error = error + 1;
			end
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_READ = 0;
	endtask
	
	
	//////////////////////////////////////////////////
	//     Iterative Read of Halfwords to Memory    //
	//////////////////////////////////////////////////
	task burst_read_halfword;
		input int test_num;
		logic [BITS - 1 : 0] expected;
		
		// Enable Memory for Read
		MEM_READ = 1;
		
		// Burst Read Words from Memory
		for (int i = 0; i < 200; i = i + 2) begin
			MEM_ADDR = i; 
			expected = (i + 16'h8000);
			expected[31:16] = 16'hFFFF; #1;
			
			// Check for Valid Data Out
			if (MEM_DATA_OUT !== expected) begin
				$display("- ERROR on Test #%d, Read %d: Expected 0x%h from Address 0x%h, Returned 0x%h",
					test_num, i, expected, i, MEM_DATA_OUT);
				error = error + 1;
			end
			@(posedge clk);
		end
		
		// Reset all Configurations
		MEM_READ = 0;
	endtask
endmodule