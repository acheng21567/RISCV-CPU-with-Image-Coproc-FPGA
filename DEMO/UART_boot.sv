///////////////////////////////////////////////////////////////////////////////
// Program: UART_boot.sv
// 
// Project: ECE 554 Bootloader
// 
// Author: Team Sachima
//
// Description:
//  - UART Bootloader
//
//  - Inputs:
//      clk:    			Global Clock 
//      rst_n:    			Global Active Low Reset 
//      RX:    			    Input data to send
//      
//  - Outputs:
//      wdata_data:			Serial data output
//      wdata_addr:			Serial address output
//      dst:		        100 for IM, 010 for DM, 001 for image buffer
//		bootloading:	    indicates it is boot loading, active high
///////////////////////////////////////////////////////////////////////////////

module UART_boot(clk, rst_n, RX, wdata_data, wdata_addr, dst, bootloading);
    // Import Common Parameters Package
	import common_params::*;

    input clk, rst_n;
    input RX;
    output logic [IB_DW - 1 : 0] wdata_data;
    output logic [15 : 0] wdata_addr;
    output logic [2:0] dst;
    output logic bootloading;


    ////////////////////////////////////////////////////////////
    /////////////////// Intermediate Signals ///////////////////
    ////////////////////////////////////////////////////////////
	logic clr_rdy, rdy;
    logic dst_en, we, done;
    logic [10:0] counter_addr;
    logic [2:0] dst_temp; 
    logic [10:0] counter_data;
    logic [1:0] status;
    logic [7:0] rx_data;
    logic [10:0] data_width;

    // State Enumeration
    typedef enum logic [2:0]{IDLE=3'b000, CTRL, ADDR, DATA, DONE} state_t;
    state_t state, nxt_state;


    ////////////////////////////////////////////////////////////
    /////////////////////// Module Operation ///////////////////
    ////////////////////////////////////////////////////////////

    UART_RX iRX(.clk(clk), .rst_n(rst_n), .baud_DB(BAUD_RATE), .RX(RX), .clr_rdy(clr_rdy),
				.rx_data(rx_data), .rdy(rdy));

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= nxt_state;
        end
    end

    //update target memory
    always_ff @(posedge clk) begin
        if (dst_en) begin
            dst_temp <= rx_data[2:0];
        end 
    end

    //combine destination with write enable
    assign dst = dst_temp & {3{done}};


    //update address package
    always_ff @(posedge clk) begin
        if (status != 2'b10) begin
            counter_addr <= 1;
        end
        else if(status == 2'b10 && we) begin
            wdata_addr <= {rx_data, wdata_addr[15 : 8]};
            counter_addr <= counter_addr + 1;
        end
    end


    assign data_width = (dst_temp == IMAGE_BUFFER)? IB_DW_PB : I_D_MEM_DW_PB;

    //update data package
    always_ff @(posedge clk) begin
        if (status != 2'b11) begin
            counter_data <= 1;
        end
        else if(status == 2'b11 && we) begin
            wdata_data <= {rx_data, wdata_data[IB_DW - 1 : 8]};
            counter_data <= counter_data + 1;
        end
    end

    always_comb begin
        nxt_state = state;
        we = 1'b0;
        clr_rdy = 1'b0;
        status = 2'b00;
        done = 1'b0;
        dst_en = 1'b0;
        bootloading = 1'b0;
        case (state)
            IDLE: begin
                //start bootloading
                if (RX == 0)begin
                    nxt_state = CTRL;
                    bootloading = 1'b1;
                end
                status = 2'b00;
            end
            //one byte dertermining where to access
            CTRL: begin
                //done
                if (rdy)begin
                    nxt_state = ADDR;
                    dst_en = 1'b1;
                    we = 1'b1;
                    clr_rdy = 1'b1;
                end
                status = 2'b01;
                bootloading = 1'b1;            
            end
            //memory address to access
            ADDR: begin
                //ADDRESS COMPLETE
                if ((rdy) && counter_addr == ADDR_WIDTH_PB)begin
                    nxt_state = DATA;
                    we = 1'b1;
                    clr_rdy = 1'b1;
                end
                //done one byte
                else if(rdy)begin
                    we = 1'b1;
                    clr_rdy = 1'b1;
                end
                status = 2'b10;
                bootloading = 1'b1;
            end
            //data writing into the memory
            DATA: begin
                //DATA COMPLETE
                if ((rdy) & (counter_data == data_width))begin
                    nxt_state = DONE;
                    we = 1'b1;
                    clr_rdy = 1'b1;
                end
                //done one byte
                else if(rdy)begin
                    we = 1'b1;
                    clr_rdy = 1'b1;
                end
                status = 2'b11;
                bootloading = 1'b1;
            end
            DONE: begin
                //ready to write
                nxt_state = IDLE;
                done = 1'b1;
                bootloading = 1'b1;
            end
            default: begin
                nxt_state = IDLE;
                status = 2'b00;
            end
        endcase
    end


endmodule