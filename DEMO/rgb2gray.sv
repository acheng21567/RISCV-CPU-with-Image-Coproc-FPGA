// /////////////////////////////////////////////////////////////////////////////
// Program: rgb2gray.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - A module for converting a 12-bit RGB pixel into a 12-bit grayscale pixel
// 
//  - Inputs:
//     rgb_in [11:0]: 	    12-bit pixel in {R[3:0],G[3:0],B[3:0]} format
// 
//  - Outputs:
//     gray_out [11:0]: 	12-bit grayscale pixel, extend 3 times from a 4-bit 
//                          grayscale pixel calculated
// /////////////////////////////////////////////////////////////////////////////

module rgb2gray(
    input logic [11:0] rgb_in,
    output logic [11:0] gray_out
);
    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    logic [7:0] gray;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
    // gray = (5 * R + 9 * G + 2 * B) / 16
    assign gray = ( ((rgb_in[11:8] << 2) + rgb_in[11:8]) + 
                    ((rgb_in[7:4] << 3) + rgb_in[7:4]) +
                    (rgb_in[3:0] << 1));

    // repeat the 4-bit gray value 3 times to fill the 3 channels
    assign gray_out = {3{gray[7:4]}};
endmodule