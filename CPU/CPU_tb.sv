///////////////////////////////////////////////////////////////////////////////
// Program: CPU_tb.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level CPU Testbench Environment
///////////////////////////////////////////////////////////////////////////////


`default_nettype none
module CPU_tb ();
	// Import Common Parameters Package
	import common_params::*;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Testbench Signals /////////////////////
    ////////////////////////////////////////////////////////////
	logic clk, rst_n, HLT, cycle_cnt_en, cycle_count_rst;
	int error, test_num, cycle_count;
	logic [BITS - 1 : 0] expected_regs [0 : 31];
	string current_test;
	string base_addr = "C:\\Users\\ashwi\\OneDrive - UW-Madison\\School\\ECE 554\\Mini Labs\\ECE554-SP24\\Final_Project\\CPU\\tests\\";
 	
	/* string tests[] = '{"addi", "add", "and", "andi", "auipc", "or", "ori", "sll",
		"slli", "sra", "srai", "srl", "srli", "sub", "xor", "xori", "slt", "slti", "sltiu",
		"sltu", "mem_W", "mem_H", "mem_B", "mem_HU", "mem_BU",
		"lui", "jal", "jalr", "beq", "bne", "bge", "blt", "bgeu", "bltu", 
		"branch_stall", "branchr", "load_to_branch", "load_to_use", "merge_sort"}; */
	
	string tests[] = '{"IO_TEST"};
	
	// DUT Probes
	logic [BITS - 1 : 0] REG_DATA1, REG_DATA2, REG_DEST_DATA,
		MEM_ADDR, MEM_DATA_IN, MEM_DATA_OUT, PC, PC_NEXT, Inst,
		IMM32, TARGET_ADDR, ALU_A, ALU_B;
	logic [BITS - 1 : 0] REG_BANK [0 : 31];
	logic [9:0] SW, LEDR;
	logic [$clog2(BITS) - 1 : 0] SR1, SR2, RD, SHAMT;
	logic [3:0] KEY;
	logic REG_WRITE, MEM_READ, MEM_WRITE, PC_SRC, PC_EN, HALT, 
		BRANCH_TAKEN, JUMP, RX;
	mem_data_t MEM_DATA_TYPE;
	branch_t BRANCH_TYPE;
	alu_t ALU_OP;



	////////////////////////////////////////////////////////////
    ////////////////// Module Instantiation ////////////////////
    ////////////////////////////////////////////////////////////
	Microprocessor DUT (.clk(clk), .rst_n(rst_n), .RX(RX), .SW(SW), .LEDR(LEDR),
		.KEY(KEY), .HLT(HLT));
	
 	//////////////////////////
	// DUT PROBE CONNECTION //
	//////////////////////////
	assign REG_BANK = DUT.CPU.ID.rf.REG_BANK; // Register File
	
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Clock Generation //////////////////////
    ////////////////////////////////////////////////////////////
	always #50 clk = ~clk;
	
	// Cycle Count
	always_ff @(posedge clk, posedge cycle_count_rst) begin
		if (cycle_count_rst) begin
			cycle_count <= '0;
		end
		if (cycle_cnt_en) begin
			cycle_count <= cycle_count + 1;
		end
	end
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Stimulus & Checking ////////////////////
    ////////////////////////////////////////////////////////////
	initial begin
		// Default Testbench & DUT Values
		clk = 0;
		error = 0;
		test_num = 0;
		cycle_cnt_en = 0;
		cycle_count_rst = 0;
		SW = $random();
		KEY = $random();
		DUT.COPROC_STS = $random();
		
		// Execute alll Tests in List
		$display("----- SIMULATION START -----");
		foreach (tests[i]) begin
			current_test = tests[i]; // Retrieve Current Test from List
		
			$display("----- %s Test -----", current_test);
			run_test(test_num, current_test); // Execute Test
			
			test_num = test_num++; $display("\n");
		end
		@(posedge clk);
		
		
		// Display Error or Success Message
		if (error) begin
			$display("- FAILED: %d Errors Occurred During Simulation", error);
		end
		else begin
			$display("----- ALL TESTS PASSED -----");
		end
		$stop();
	end
	
	
	////////////////////////////////////////////////////////////
	// Task: run_test
	// Description:
	//	- Resets CPU, Loads Instruction Memory with respective
	//		Test's HEX Code, Deasserts Reset & waits until 
	//		Program Completion (HLT Detected).
	//	- Calls Compare Regs Task to validate Register Output
	////////////////////////////////////////////////////////////
	task run_test;
		input int test_num;
		input string current_test;
		
		// Reset Device
		rst_n = 0;
		cycle_count_rst = 1;
		@(posedge clk);
		
		// Load Instruction Memory
		$readmemh({base_addr, current_test, ".hex"}, DUT.CPU.IF.i_mem.instr_mem);
		@(posedge clk);
		
		// Deassert Reset
		rst_n = 1;
		cycle_count_rst = 0;
		cycle_cnt_en = 1;
		@(posedge clk);
		
		// Wait until Test Completes 
		@(posedge HLT);
		cycle_cnt_en = 0;
		@(posedge clk);
		
		// Compare Registers @ Completion
		//compare_regs(current_test, test_num);
		@(posedge clk);
	endtask
	
	
	////////////////////////////////////////////////////////////
	// Task: compare_regs
	// Description:
	//	- Loads Respective Test's expected Register Output, and
	//		compares CPU's Register File with expected Values
	////////////////////////////////////////////////////////////
	task compare_regs;
		input string current_test;
		input int test_num;
		
		// Load Expected Register Dump
		$readmemh({base_addr, current_test, "_expected.hex"}, expected_regs);
		
		// Compare Registers
		for (int i = 0; i < 32; i++) begin
			if ((i !== 0) && (REG_BANK[i] !== expected_regs[i])) begin
				$display("- ERROR on Test #%d Reg Dump: Expected 0x%h on Reg %d, Returned 0x%h", 
				test_num, expected_regs[i], i, REG_BANK[i]);
				error++;
			end
		end
	endtask
endmodule
`default_nettype wire