///////////////////////////////////////////////////////////////////////////////
// Program: CPU_tb.sv
// 
// Project: ECE 554 RISC-V 
// 
// Author: Team Sachima
//
// Description:
//  - RISC-V Base 32I Top-Level CPU Simulation Environment
///////////////////////////////////////////////////////////////////////////////


`default_nettype none
module CPU_tb ();
	// Import Common Parameters Package
	import common_params::*;
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Testbench Signals /////////////////////
    ////////////////////////////////////////////////////////////
	logic [9:0] LEDR, SW;
	logic [3:0] KEY;
	logic clk, rst_n, HLT, cycle_cnt_en, cycle_count_rst, instr_cnt_en, instr_cnt_rst;
	int error, cycle_count, instr_cnt;
	string base_addr = "C:/Users/asus/Desktop/ECE554/ECE554-SP24/Final_Project/CPU/simulation/";
	// string base_addr = "C:\\Users\\ashwi\\OneDrive - UW-Madison\\School\\ECE 554\\Mini Labs\\ECE554-SP24\\Final_Project\\CPU\\simulation\\";
	string current_test = "wiscv";
	
	

	////////////////////////////////////////////////////////////
    ////////////////// Module Instantiation ////////////////////
    ////////////////////////////////////////////////////////////
	Microprocessor DUT(.clk(clk), .rst_n(rst_n), .RX(), .SW(SW), .LEDR(LEDR), .KEY(KEY), .HLT(HLT));
	
	
	////////////////////////////////////////////////////////////
    //////////////////// Clock Generation //////////////////////
    ////////////////////////////////////////////////////////////
	always #2 clk = ~clk;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Simulation Behavior ////////////////////
    ////////////////////////////////////////////////////////////
	
	// Cycle Count
	always_ff @(posedge clk, posedge cycle_count_rst) begin
		if (cycle_count_rst) begin
			cycle_count <= '0;
		end
		if (cycle_cnt_en) begin
			cycle_count <= cycle_count + 1;
		end
	end
	
	// Instruction Count
	always_ff @(posedge clk, posedge instr_cnt_rst) begin
		if (instr_cnt_rst) begin
			instr_cnt <= '0;
		end
		if (DUT.CPU.IF.PC_EN) begin
			instr_cnt <= instr_cnt + 1;
		end
	end
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////// Stimulus & Checking ////////////////////
    ////////////////////////////////////////////////////////////
	initial begin
		// Default Testbench & DUT Values
		clk = 0;
		error = 0;
		cycle_cnt_en = 0;
		cycle_count_rst = 1;
		instr_cnt_rst = 1;
		rst_n = 0;
		SW = 0;
		KEY = 0;
		
		// Load Instruction Memory
		repeat(5) @(posedge clk);
		$readmemh({base_addr, current_test, ".hex"}, DUT.CPU.IF.i_mem.instr_mem);
		// $readmemh({base_addr, current_test, "_bank0.hex"}, DUT.CPU.MEM.d_mem.BANK3.RAM);
		// $readmemh({base_addr, current_test, "_bank1.hex"}, DUT.CPU.MEM.d_mem.BANK2.RAM);
		// $readmemh({base_addr, current_test, "_bank2.hex"}, DUT.CPU.MEM.d_mem.BANK1.RAM);
		// $readmemh({base_addr, current_test, "_bank3.hex"}, DUT.CPU.MEM.d_mem.BANK0.RAM);
		@(posedge clk);
		
		$display("----- SIMULATION START -----");
		// Deassert Reset
		rst_n = 1;
		cycle_count_rst = 0;
		instr_cnt_rst = 0;
		cycle_cnt_en = 1;
		

		// Call on Task for Generation of I/O Signals
		gen_io_signals();
		
		// Wait for End of Program
		// @(posedge HLT);	

		
		cycle_cnt_en = 0;
		$display("----- SIMULATION COMPLETED -----");
		$display("- Cycle Count: %d", cycle_count);
		$display("- Instr Count: %d", instr_cnt);
		$stop();
	end



///////////////////////////////////////////////////////////////////////////////
// Task for Generation of I/O Signals to Replicate User Activity
///////////////////////////////////////////////////////////////////////////////
task gen_io_signals;
	// Wait for Initial Coprocessor Done
	// @(posedge DUT.COPROC_STS[1]); // Wait Until Coprocessor Done
	
	// Wait for some time, then initiate
	// repeat(10) @(posedge clk);
	// KEY = 4'b0001;
	// repeat(25) @(posedge clk);
	SW = 10'b0000000111;
	KEY = 4'b0010;
	repeat(15) @(posedge clk);
	KEY = 4'b0000;
	
	repeat(7)@(posedge DUT.COPROC_STS[1]); // Wait Until Coprocessor Done
	repeat(150) @(posedge clk);
endtask
endmodule
`default_nettype wire