// /////////////////////////////////////////////////////////////////////////////
// Program: basic_ALU.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - A basic ALU that performs basic image processing operations on 12-bit pixel values
//     operations include inversion, color selection, contrast adjustment, and thresholding
// 
//  - Inputs:
//     pixel_in [11:0]: 	12-bit pixel to be converted
//     func [1:0]: 	        Image processing opcode
// 
//  - Outputs:
//     pixel_out: 	        12-bit pixel after conversion
// /////////////////////////////////////////////////////////////////////////////

module basic_ALU(
    input logic [11:0] pixel_in,
    input logic [1:0] func,
    output logic [11:0] pixel_out
);

    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    localparam THRESH = 4'b0110;
    localparam MAX = 4'b1111;
    localparam MIN = 4'b0000;
    localparam CONTRAST_ADJUST = 12'h080;
    localparam CONTRAST_MAX = 12'h0FF;
    localparam CONTRAST_MIN = 12'h010;
    localparam COLOR_THRESH_0 = 4'b0010;
    localparam COLOR_THRESH_1 = 4'b0100;
    localparam COLOR_THRESH_2 = 4'b1001;
    localparam COLOR_THRESH_3 = 4'b1101;
    localparam COLOR_0 = 12'h000;
    localparam COLOR_1 = 12'h00F;
    localparam COLOR_2 = 12'h0F0;
    localparam COLOR_3 = 12'hF9C;
    localparam COLOR_4 = 12'hF00;

    logic [11:0] invert, color, contrast, thresh;
    logic signed [11:0] r, g, b;
    logic signed [11:0] r_contrast, g_contrast, b_contrast;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
    assign invert = ~pixel_in;

    // Assign the color based on the pixel grayscale value
    always_comb begin
        if (pixel_in[7:4] <= COLOR_THRESH_0)
            color = COLOR_0;
        else if (pixel_in[7:4] <= COLOR_THRESH_1)
            color = COLOR_1;
        else if (pixel_in[7:4] <= COLOR_THRESH_2)
            color = COLOR_2;
        else if (pixel_in[7:4] <= COLOR_THRESH_3)
            color = COLOR_3;
        else
            color = COLOR_4;
    end

    // Extend 4-bit inputs to 8-bit signed values for more range in calculations
    assign r = {4'b0, pixel_in[11:8], 4'b0};  // Moving the bits to a higher range
    assign g = {4'b0, pixel_in[7:4], 4'b0};
    assign b = {4'b0, pixel_in[3:0], 4'b0};

    // Apply contrast by emphasizing deviation from the midpoint
    assign r_contrast = (((r - CONTRAST_ADJUST) * 3) >> 1) + CONTRAST_ADJUST;
    assign g_contrast = (((g - CONTRAST_ADJUST) * 3) >> 1) + CONTRAST_ADJUST;
    assign b_contrast = (((b - CONTRAST_ADJUST) * 3) >> 1) + CONTRAST_ADJUST;

    // Clamping results to 8-bit values and reducing back to 4-bit
    assign contrast = {
        (r_contrast > $signed(CONTRAST_MAX) ? MAX : (r_contrast < $signed(CONTRAST_MIN) ? MIN : r_contrast[7:4])),
        (g_contrast > $signed(CONTRAST_MAX) ? MAX : (g_contrast < $signed(CONTRAST_MIN) ? MIN : g_contrast[7:4])),
        (b_contrast > $signed(CONTRAST_MAX) ? MAX : (b_contrast < $signed(CONTRAST_MIN) ? MIN : b_contrast[7:4]))
    };

    // Thresholding the pixel values
    assign thresh = {
        pixel_in[11:8] > THRESH ? MAX : MIN,
        pixel_in[7:4]  > THRESH ? MAX : MIN,
        pixel_in[3:0]  > THRESH ? MAX : MIN
    };

    // Select the output based on the function
    always_comb begin
        case (func)
            2'b00: pixel_out = invert;
            2'b01: pixel_out = color;
            2'b10: pixel_out = contrast;
            default: pixel_out = thresh;
        endcase
    end

endmodule