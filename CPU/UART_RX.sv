//////////////////////////////////////////////////////////////////////////////////
// Project: MiniLab1
// Module: UART_RX
// Description: Uart Receiver Driver with configurable Baud Rate
//
// Inputs:
//	- clk: 				Global CLK
//	- rst_n: 			Global Reset
//	- RX: 				Received Serial Bit
//	- clr_rdy:			Flag from Master to Acknowledge Data Received
//	- baud_DB:			RX Baud Rate
//
// Outputs:
//	- rdy:				Flag Signifying data valid at output after transaction
//	- rx_data:			Data Packet Received
//////////////////////////////////////////////////////////////////////////////////

module UART_RX(clk, rst_n, RX, rdy, rx_data, clr_rdy, baud_DB);

	////////////////////////////////////////////////////////////
    //////////////////// Module Port List //////////////////////
    ////////////////////////////////////////////////////////////
	input [12:0] baud_DB;
	input clk, rst_n, RX, clr_rdy;
	output logic [7:0] rx_data;
	output logic rdy;
	


	////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	
	// State Enumeration
	typedef enum logic {IDLE, RX_STATE} state_t;
	state_t state, nxt_state;
	
	logic [12:0] baud_cnt;				// UART TX Baud Rate Generator
	logic [12:0] stored_baud_DB;		// Currently Stored Baud Rate (Avoids new baud rate affecting current transaction)
	logic [8:0] shift_reg;				// TX Data with Stop Bit to be shifted out on TX
	logic [3:0] bit_cnt;				// # of Shifts Performed
	logic rx_ff1, rx_ff2;				// back to back flops for meta-stability of RX input
	logic start, set_rdy, receiving;	// SM Output Control
	logic shift;
	
	
	
	////////////////////////////////////////////////////////////
    /////////////////////// Module Operation ///////////////////
    ////////////////////////////////////////////////////////////

	// Bit Counter: Maintain # of Shifts in Current Transaction
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			bit_cnt <= 'h0;
		end
		else if (start) begin
			bit_cnt <= 'h0;
		end
		else if (shift) begin
			bit_cnt <= bit_cnt + 1;
		end
	end
	
	// Store Baud Rate at beginning of each transaction
	// to avoid baud rate changing mid transaction
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			stored_baud_DB <= baud_DB;
		end
		else if (start) begin
			stored_baud_DB <= baud_DB;
		end
	end
	
	// Infer UART Baud clk Generator
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			baud_cnt <= baud_DB >> 1;		// Default to 1/2 Baud Rate @ Reset (Shift to Middle of Period)
		end
		else if (start) begin
			baud_cnt <= baud_DB >> 1;		// Set to 1/2 Baud Rate @ Start of Transmission (Shift to Middle of Period)
		end
		else if (shift) begin
			baud_cnt <= stored_baud_DB;		// Load registered Baud Rate in middle of Transaction
		end
		else if (receiving) begin
			baud_cnt <= baud_cnt - 1;		// Decrement Count while in transmission state
		end
	end

	// Infer shift register
	always_ff @(posedge clk) begin
		if (shift) begin
			shift_reg <= {rx_ff2,shift_reg[8:1]};   // LSB comes in first
		end
	end
	

	// rdy will be implemented with a flop
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			rdy <= 1'b0;
		end
		else if (start || clr_rdy) begin
			rdy <= 1'b0;			// knock down rdy when new start bit detected
		end
		else if (set_rdy) begin
			rdy <= 1'b1; 			// Assert Rdy after transaction completion
		end
	end

	// Double Flop RX input to avoid meta-stability
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			rx_ff1 <= 1'b1;			// reset to idle state
			rx_ff2 <= 1'b1;
		end
		else begin
			rx_ff1 <= RX;
			rx_ff2 <= rx_ff1;
		end
	end
	
	// Shift RX Data Out when Baud Rate Counter is Empty
	assign shift = ~|baud_cnt;
	
	// Assign RX input to MSB of shift reg
	assign rx_data = shift_reg[7:0];
	
	
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
		start         = 0;
		set_rdy       = 0;
		receiving     = 0;
		nxt_state     = state;	// always a good idea to default to IDLE state

		case (state)
			IDLE : begin
				// Transmission to Receive if START Bit Received
				if (!rx_ff2) begin
					nxt_state = RX_STATE;
					start = 1;
				end
			end
			
			default : begin		// Default to Receive State
				receiving = 1;
				
				if (bit_cnt == 4'b1010) begin
					set_rdy = 1;
					nxt_state = IDLE;
				end
			end
		endcase
	end
endmodule