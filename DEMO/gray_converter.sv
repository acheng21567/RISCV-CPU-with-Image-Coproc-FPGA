// /////////////////////////////////////////////////////////////////////////////
// Program: gray_converter.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Gray scale converter module for converting 9 color pixels into 9 grayscale pixels
// 
//  - Inputs:
//     rgb_in0 [35:0]: 	    3 color pixels to be converted into grayscale
//     rgb_in1 [35:0]: 	    3 color pixels to be converted into grayscale, [23:12] is the pixel for nonovulation operations
//     rgb_in2 [35:0]: 	    3 color pixels to be converted into grayscale
//     gray_out0 [35:0]: 	3 grayscale pixels converted
//     gray _out1 [35:0]: 	3 grayscale pixels converted
//     gray _out2 [35:0]: 	3 grayscale pixels converted
// 
//  - Outputs:
//     gray _out2 [35:0]: 	3 grayscale pixels converted
// /////////////////////////////////////////////////////////////////////////////

module gray_converter(
    input logic [35:0] rgb_in0,
    input logic [35:0] rgb_in1,
    input logic [35:0] rgb_in2,
    output logic [35:0] gray_out0,
    output logic [35:0] gray_out1,
    output logic [35:0] gray_out2
);
    ////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////

    // Instantiate 9 gray converter modules for the whole 3x3 kernel
    rgb2gray rgb2gray0[8:0](
        {rgb_in0, rgb_in1, rgb_in2}, 
        {gray_out0, gray_out1, gray_out2}); 

endmodule