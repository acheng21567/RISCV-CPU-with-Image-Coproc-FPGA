// /////////////////////////////////////////////////////////////////////////////
// Program: proc_element.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Processing element module for image processing operations, 
//     including grayscale conversion, basic ALU operations, and convolution operations
// 
//  - Inputs:
//     clk: 	            Global clock signal for 25MHz
//     rst_n: 	            Global active low reset
//     rgb_in0 [35:0] : 	3 color pixels to be converted into grayscale
//     rgb_in1 [35:0]: 	    3 color pixels to be converted into grayscale, [23:12] is the pixel for nonovulation operations
//     rgb_in2 [35:0]: 	    3 color pixels to be converted into grayscale
//     func [2:0]: 	        Image processing opcode passed from the host processor
//     gray: 	            Asserted from the host processor if the operation should be done in grayscale
//     start: 	            Asserted from the host processor to start the image processing
//     cnt_start: 	        Asserted by the image DMA to enable write enable to video memory
//     done: 	            Asserted by the image DMA signaling the completion of image processing
// 
//  - Outputs:
//     we_reg: 	            Pipelined write enable to write pixel into video memory
//     start_reg: 	        Pipelined start signaling start the image processing
//     done_reg: 	        Pipelined done signaling the completion of image processing
//     data_out [11:0]: 	Pixel to be written into video memory
// /////////////////////////////////////////////////////////////////////////////

module proc_element(
    input logic clk,
    input logic rst_n,
    input logic [35:0] rgb_in0,
    input logic [35:0] rgb_in1,
    input logic [35:0] rgb_in2,
    input logic [2:0] func,
    input logic gray,
    input logic start,
    input logic cnt_start,
    input logic done,
    output logic we_reg,
    output logic start_reg,
    output logic done_reg,
    output logic [11:0] data_out
);

    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    logic [35:0] gray_in0, gray_in1, gray_in2;
    logic [35:0] pixel_in0, pixel_in1, pixel_in2;
    logic [35:0] pixel_in0_reg, pixel_in1_reg, pixel_in2_reg;
    logic [11:0] basic_ALU_out, conv_out;
    logic [2:0] func_reg;
    logic prev_rdy, we;
    
	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////
    gray_converter gray_converter0(
        .rgb_in0(rgb_in0),
        .rgb_in1(rgb_in1),
        .rgb_in2(rgb_in2),
        .gray_out0(gray_in0),
        .gray_out1(gray_in1),
        .gray_out2(gray_in2)
    );
    
    basic_ALU basic_ALU0(
        .pixel_in(pixel_in1_reg[23:12]),
        .func(func_reg[1:0]),
        .pixel_out(basic_ALU_out)
    );

    conv_array conv_array0(
        .pixel_in0(pixel_in0_reg),
        .pixel_in1(pixel_in1_reg),
        .pixel_in2(pixel_in2_reg),
        .func(func_reg[1:0]),
        .data_out(conv_out)
    );

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
    assign pixel_in0 = gray ? gray_in0 : rgb_in0;
    assign pixel_in1 = gray ? gray_in1 : rgb_in1;
    assign pixel_in2 = gray ? gray_in2 : rgb_in2;

    // choose the output data from basic_ALU or conv_array based on the function
    assign data_out = func_reg[2] ? conv_out : basic_ALU_out;

    // write enable signal for both recent image and video memory pixel writes
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            we <= 0;
        end
        else if (cnt_start) begin
            we <= 1;
        end
        else if (done) begin
            we <= 0;
        end
    end

    // pipeline all input signals for pixel operations to reduce critical path
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            pixel_in0_reg <= '0;
            pixel_in1_reg <= '0;
            pixel_in2_reg <= '0;
            func_reg <= 3'h7;
            we_reg <= '0;
            start_reg <= 0;
            done_reg <= 0;
        end
        else begin
            pixel_in0_reg <= pixel_in0;
            pixel_in1_reg <= pixel_in1;
            pixel_in2_reg <= pixel_in2;
            func_reg <= func;
            we_reg <= we;
            start_reg <= start;
            done_reg <= done;
        end
    end

endmodule