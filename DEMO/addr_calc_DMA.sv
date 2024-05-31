// /////////////////////////////////////////////////////////////////////////////
// Program: addr_calc_DMA.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Address calculation module for the image DMA that calculates the read and write addresses for the image buffer
// 
//  - Inputs:
//     clk: 	Global clock signal for 25MHz
//     rst_n: 	Global active low reset
//     start: 	Start signal asserted from the host processor to initiate the image processing
// 
//  - Outputs:
//     we_img_buf: 	Write enable for writing to image buffer
//     raddr [7:0]: 	8-bit read address to read from the image buffer
//     waddr [8:0]: 	9-bit write address to write into the image buffer
//     col_cnt [7:0]: 	8-bit column counter counting from 0 to 255, specifying the column that is being processed
//     reg_sel [2:0]: 	3-bit one hot register selecting one of the three registers to be written
//     done: 	Done signal asserted for one cycle, showing the completion of image processing
//     rdy: 	Ready signal asserted when image processor is not in processing state
//     reg2_rst: 	Signal asserted when reaching the last row of image buffer, ensuring padding for convolution
//     cnt_start: 	Asserted to set write enable for VGA_driver
//     re: 	Read enable indicating that new rdata from image buffer is available
// /////////////////////////////////////////////////////////////////////////////

module addr_calc_DMA(
    input logic clk,
    input logic rst_n,
    input logic start,
    output logic we_img_buf,
    output logic [7:0] raddr,
    output logic [8:0] waddr,
    output logic [7:0] col_cnt,
    output logic [2:0] reg_sel,
    output logic done,
    output logic rdy,
    output logic reg2_rst,
    output logic cnt_start,
    output logic re
);

    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    typedef enum logic [2:0] { IDLE, READ_START, COMP, READ, WRITE } state_t;
    logic [7:0] row_cnt;
    state_t state, nxt_state;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // State machine to control the address calculation
    always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

    always_comb begin
        nxt_state = state;
        cnt_start = 0;
        re = 0;
        we_img_buf = 0;
        done = 0;
        rdy = 0;

        case (state)
            // Start the read process
            READ_START: begin
                re = 1;
                cnt_start = 1;
                nxt_state = COMP;
            end
            // Computation state until a row is processed
            COMP: begin
                // If the row counter is at the end of the image, finish
                if (~|row_cnt & ~waddr[8]) begin
                    done = 1;
                    rdy = 0;
                    nxt_state = IDLE;
                end
                // If the column counter is at the end of the row, move to the next row
                else if (&col_cnt) begin
                    nxt_state = READ;
                end
            end
            // Read a row from the image buffer
            READ: begin
                re = 1;
                nxt_state = WRITE;
            end
            // Write a row to the image buffer
            WRITE: begin
                we_img_buf = 1;
                nxt_state = COMP;
            end
            // Default IDLE state
            default: begin
                if (start) begin
                    re = 1;
                    nxt_state = READ_START;
                end
                // Output ready signal for controlling
                else begin                
                    rdy = 1;
                end
            end
        endcase
    end

    // increment row counter to select rows for reads and writes
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            row_cnt <= '0;
        end
        else if (start) begin
            row_cnt <= '1;
        end
        else if (cnt_start) begin
            row_cnt <= row_cnt + 1;
        end
        else if (&col_cnt) begin
            row_cnt <= row_cnt + 1;
        end
    end

    // increment column counter to select center pixels for reads and writes
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            col_cnt <= '0;
        end
        else if (cnt_start) begin
            col_cnt <= '0;
        end 
        else if (cnt_start) begin
            col_cnt <= '0;
        end
        else begin
            col_cnt <= col_cnt + 1;
        end
    end

    // read addresses
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            raddr <= '0;
        end
        else if (start) begin
            raddr <= '0;
        end
        else if (re) begin
            raddr <= raddr + 1;
        end
    end

    // select which read row address should be incremented across the banks
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            reg_sel <= 3'b010;
        end
        else if (start) begin
            reg_sel <= 3'b010;
        end
        else if (re) begin
            reg_sel <= {reg_sel[1:0], reg_sel[2]};
        end
    end
    
    // write addresses
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            waddr <= 9'h100;
        end
        else if (start) begin
            waddr <= 9'h100;
        end
        else if (we_img_buf) begin
            waddr <= waddr + 1;
        end
    end

    // reset the r2 to read all 0s for the last padding row
    assign reg2_rst = &row_cnt;

endmodule