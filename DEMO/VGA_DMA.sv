// /////////////////////////////////////////////////////////////////////////////
// Program: VGA_DMA.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - VGA Direct Memory Access (DMA) module for calculating write address for video memory
// 
//  - Inputs:
//     clk: 	        Global clock signal for 25MHz
//     rst_n: 	        Global active low reset
//     we_in: 	        Signal to increase waddr and counter
//     start: 	        Asserted from the host processor to start the image processing
//     done: 	        Asserted by the image DMA signaling the completion of image processing
// 
//  - Outputs:
//     waddr [16:0]: 	17-bit write address for video memory
//     we_out: 	        Write enable for video memory
// /////////////////////////////////////////////////////////////////////////////

module VGA_DMA(
    input logic clk,
    input logic rst_n,
    input logic we_in,
    input logic start,
    input logic done,
    output logic [16:0] waddr,
    output logic we_out
);
    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    localparam IMG_WIDTH = 9'd256;

    logic [16:0] col_cnt;
    logic write_img_0;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // control write to left part of the video memory only once (show original image for comparison)
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            write_img_0 <= 0;
        end 
        else if (done) begin
            write_img_0 <= 1;
        end
    end

    // column counter for calculating video memory write address
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            col_cnt <= '0;
        end 
        else if (start) begin
            col_cnt <= '0;
        end
        // do not increment after the counter is full (check 16th bits)
        else if (we_in & ~col_cnt[16]) begin
            col_cnt <= col_cnt + 1;
        end 
    end

    // calculate video memory write address
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            waddr <= '0;
        end 
        // choose the starting address for writing the image, left start from 0, right start from 256
        else if (start) begin
            waddr <= write_img_0 ? IMG_WIDTH : '0;
        end
        else if (we_in & (&col_cnt[7:0])) begin
            waddr <= waddr + IMG_WIDTH + 1;
        end
        else if (we_in) begin
            waddr <= waddr + 1;
        end
    end

    // control to write only to valid address
    assign we_out = col_cnt[16] ? 0 : we_in;

endmodule