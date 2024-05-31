//////////////////////////////////////////////////////////////////////////////////
// Project: MiniLab1
// Module: UART_TX
// Description: Uart Transmit Driver with configurable Baud Rate
//
// Inputs:
//	- clk: 				Global CLK
//	- rst_n: 			Global Reset
//	- trmt: 			Flag initiating TX Transaction
//	- tx_data:			Data Packet to be transmitted
//	- baud_DB:			TX Driver Baud Rate
//
// Outputs:
//	- TX:				Head of FIFO on Read
//	- tx_done:			Head of FIFO on Read
//	- ACK_TRMT:			Acknowledge Incoming Data for Write
//////////////////////////////////////////////////////////////////////////////////

module UART_TX(clk, rst_n, TX, trmt, tx_data, tx_done, baud_DB, ACK_TRMT);
	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input [12:0] baud_DB;
	input [7:0] tx_data;
	input clk, rst_n, trmt;
	output logic TX, tx_done, ACK_TRMT;



	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	logic [12:0] baud_cnt;				// UART TX Baud Rate Generator
	logic [12:0] stored_baud_DB;		// Currently Stored Baud Rate (Avoids new baud rate affecting current transaction)
	logic [8:0] shift_reg;				// TX Data with Stop Bit to be shifted out on TX
	logic [3:0] bit_cnt;				// # of Shifts Performed
	logic load, trnsmttng;				// SM Input Control
	logic shift;

	// State Enumeration
	typedef enum reg {IDLE,TX_STATE} state_t;
	state_t state, nxt_state;



	////////////////////////////////////////////////////////////
    /////////////////////// Module Operation ///////////////////
    ////////////////////////////////////////////////////////////

	// Bit Counter: Maintain # of Shifts in Current Transaction
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			bit_cnt <= 'h0;
		end
		else if (load) begin
			bit_cnt <= 'h0;
		end
		else if (shift) begin
			bit_cnt <= bit_cnt + 1;
		end
	end

	// Store Baud Rate at beginning of each transaction
	// to avoid baud rate changing mid transaction
	always_ff @(posedge clk, negedge rst_n) begin
		if (~rst_n) begin
			stored_baud_DB <= baud_DB;
		end
		else if (load) begin
			stored_baud_DB <= baud_DB;
		end
	end

	// Infer UART Baud clk Generator
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			baud_cnt <= baud_DB; // Default to Baud Rate @ Reset
		end
		else if (load) begin
			baud_cnt <= baud_DB; // Reset to Baud Rate & Beginning of Transaction
		end
		else if (shift) begin
			baud_cnt <= stored_baud_DB; // Load registered Baud Rate in middle of Transaction
		end
		else if (trnsmttng) begin
			baud_cnt <= baud_cnt - 1; // Decrement Count while in transmission state
		end
	end

	// Infer shift register
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			shift_reg <= 9'h1FF; // Shift out 1's by default: IDLE HIGH
		end
		else if (load) begin
			shift_reg <= {tx_data,1'b0}; // Load Shift Reg with TX_DATA & start bit
		end
		else if (shift) begin
			shift_reg <= {1'b1,shift_reg[8:1]}; // Shift contents & fill with IDLE HIGH
		end 
	end
	
	// Shift TX Data Out when Baud Rate Counter is Empty
	assign shift = ~|baud_cnt;
	
	// assign lsb shift to TX Out Bit 
	assign TX = shift_reg[0];



	////////////////////////////////////////////////////////////
    ////////////////////// State Machine ///////////////////////
    ////////////////////////////////////////////////////////////
	
	// Infer State Registers
	always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

	// SM Output & Next State Logic
	always_comb begin
		// Default SM Outputs
		load        = 0;
		trnsmttng 	= 0;
		ACK_TRMT 	= 0;
		tx_done 	= 0;
		nxt_state   = state;	// always a good idea to default to IDLE state

		case (state)
			IDLE : begin
				if (trmt) begin
					nxt_state = TX_STATE;
					load = 1; // Load Shift Regsiter with tx_data
					ACK_TRMT = 1; // Acknowledge Transmit Input
				end
			end
			default : begin		// Default to Transmit State
				trnsmttng = 1; // shift out to TX
				
				if (bit_cnt == 4'b1010) begin
					nxt_state = IDLE;
					tx_done = 1; // Signify transaction completion
				end
			end
		endcase
	end
endmodule