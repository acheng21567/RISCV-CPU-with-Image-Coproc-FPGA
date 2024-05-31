// /////////////////////////////////////////////////////////////////////////////
// Program: pixel_sel.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Pixel selection module that selects the 3*3 convolution window from the image buffer for convolution operation
// 
//  - Inputs:
//     rdata0_in [3071:0]: 	Data read from image buffer and stored in the register in image_DMA 
//     rdata1_in [3071:0]: 	Data read from image buffer and stored in the register in image_DMA 
//     rdata2_in [3071:0]: 	Data read from image buffer and stored in the register in image_DMA 
//     col_cnt [7:0]: 	8-bit column counter from 0 to 255, choosing the rdata_out from rdata_in
//     reg_sel [2:0]: 	3-bit one hot register formatting the rdata_out
// 
//  - Outputs:
//     rdata0_out [35:0]: 	First row of data for a 3*3 convolution window, 3 pixels * 4 pixels/channel * 3 channels
//     rdata1_out [35:0]: 	Second row of data for a 3*3 convolution window, for non-convolution calculation, the processed pixel is in [23:12]
//     rdata2_out [35:0]: 	Third row of data for a 3*3 convolution window
// /////////////////////////////////////////////////////////////////////////////

module pixel_sel(
    input logic [3071:0] rdata0_in,
    input logic [3071:0] rdata1_in,
    input logic [3071:0] rdata2_in,
    input logic [7:0] col_cnt,
    input logic [2:0] reg_sel,
    output logic [35:0] rdata0_out,
    output logic [35:0] rdata1_out,
    output logic [35:0] rdata2_out
);

    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    localparam PIXEL_WIDTH = 12;
    localparam IMG_WIDTH = 256;

    logic [3095:0] tmp0, tmp1, tmp2;
    logic [11:0] pixel00, pixel01, pixel02, pixel10, pixel11, pixel12, pixel20, pixel21, pixel22;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // simulate the side paddings of the image for convolution operation
    assign tmp0 = {PIXEL_WIDTH'(0), rdata0_in, PIXEL_WIDTH'(0)};
    assign tmp1 = {PIXEL_WIDTH'(0), rdata1_in, PIXEL_WIDTH'(0)};
    assign tmp2 = {PIXEL_WIDTH'(0), rdata2_in, PIXEL_WIDTH'(0)};

    // generate the muxes for selecting the pixels from a row of 256 pixels
    always_comb begin
        pixel00 = (col_cnt > 0)   ? tmp0[(col_cnt-1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);
        pixel10 = (col_cnt > 0)   ? tmp1[(col_cnt-1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);
        pixel20 = (col_cnt > 0)   ? tmp2[(col_cnt-1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);

        pixel01 = tmp0[col_cnt*PIXEL_WIDTH +: PIXEL_WIDTH];
        pixel11 = tmp1[col_cnt*PIXEL_WIDTH +: PIXEL_WIDTH];
        pixel21 = tmp2[col_cnt*PIXEL_WIDTH +: PIXEL_WIDTH];

        pixel02 = (col_cnt < (IMG_WIDTH - 1)) ? tmp0[(col_cnt+1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);
        pixel12 = (col_cnt < (IMG_WIDTH - 1)) ? tmp1[(col_cnt+1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);
        pixel22 = (col_cnt < (IMG_WIDTH - 1)) ? tmp2[(col_cnt+1)*PIXEL_WIDTH +: PIXEL_WIDTH] : PIXEL_WIDTH'(0);
    end

    // reorganize the pixel order for convolutions based on row_sel_onehot
    always_comb begin
        case (reg_sel)
            3'b100: begin
                rdata0_out = {pixel00, pixel01, pixel02};
                rdata1_out = {pixel10, pixel11, pixel12};
                rdata2_out = {pixel20, pixel21, pixel22};
            end
            3'b001: begin
                rdata0_out = {pixel10, pixel11, pixel12};
                rdata1_out = {pixel20, pixel21, pixel22};
                rdata2_out = {pixel00, pixel01, pixel02};
            end
            3'b010: begin
                rdata0_out = {pixel20, pixel21, pixel22};
                rdata1_out = {pixel00, pixel01, pixel02};
                rdata2_out = {pixel10, pixel11, pixel12};
            end
            default: begin
                rdata0_out = '0;
                rdata1_out = '0;
                rdata2_out = '0;
            end
        endcase
    end


endmodule