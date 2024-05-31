// /////////////////////////////////////////////////////////////////////////////
// Program: conv_array.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - A convolution array that performs 3x3 convolution on 12-bit pixel values separated into R, G, and B channels
//     operations include inversion, color selection, contrast adjustment, and thresholding
// 
//  - Inputs:
//     pixel_in0 [35:0]: 	36-bit 3 pixels to be converted
//     pixel_in1 [35:0]: 	36-bit 3 pixels to be converted
//     pixel_in2 [35:0]: 	36-bit 3 pixels to be converted
//     func [1:0]: 	        Image processing opcode
// 
//  - Outputs:
//     data_out [11:0]: 	12-bit pixel after conversion
// /////////////////////////////////////////////////////////////////////////////

module conv_array(
    input logic [35:0] pixel_in0,
    input logic [35:0] pixel_in1,
    input logic [35:0] pixel_in2,
    input logic [1:0] func,
    output logic [11:0] data_out
);

	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////

    // Split the convolution operation into 3 separate units for R, G, and B channels 
    conv_unit conv_R(
        .color_in00(pixel_in0[11:8]),
        .color_in01(pixel_in0[23:20]),
        .color_in02(pixel_in0[35:32]),
        .color_in10(pixel_in1[11:8]),
        .color_in11(pixel_in1[23:20]),
        .color_in12(pixel_in1[35:32]),
        .color_in20(pixel_in2[11:8]),
        .color_in21(pixel_in2[23:20]),
        .color_in22(pixel_in2[35:32]),
        .func(func),
        .data_out(data_out[11:8])
    );
    conv_unit conv_G(
        .color_in00(pixel_in0[7:4]),
        .color_in01(pixel_in0[19:16]),
        .color_in02(pixel_in0[31:28]),
        .color_in10(pixel_in1[7:4]),
        .color_in11(pixel_in1[19:16]),
        .color_in12(pixel_in1[31:28]),
        .color_in20(pixel_in2[7:4]),
        .color_in21(pixel_in2[19:16]),
        .color_in22(pixel_in2[31:28]),
        .func(func),
        .data_out(data_out[7:4])
    );
    conv_unit conv_B(
        .color_in00(pixel_in0[3:0]),
        .color_in01(pixel_in0[15:12]),
        .color_in02(pixel_in0[27:24]),
        .color_in10(pixel_in1[3:0]),
        .color_in11(pixel_in1[15:12]),
        .color_in12(pixel_in1[27:24]),
        .color_in20(pixel_in2[3:0]),
        .color_in21(pixel_in2[15:12]),
        .color_in22(pixel_in2[27:24]),
        .func(func),
        .data_out(data_out[3:0])
    );

endmodule