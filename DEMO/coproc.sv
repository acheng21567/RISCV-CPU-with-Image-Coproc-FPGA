// /////////////////////////////////////////////////////////////////////////////
// Program: coproc.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Image coprocessor that performs image processing on 256x256 images
// 
//  - Inputs:
//     clk: 	        Global clock signal for 25MHz
//     rst_n: 	        Global active low reset
//     VGA_CLK: 	    25MHz VGA clock from PLL block
//     start: 	        Asserted from the host processor to initiate an image processing
//     gray: 	        Asserted from the host processor indicating this image processing is in grayscale
//     img_idx: 	    Asserted from the host processor to do processing on the most recent image
//     func [2:0]: 	    Image processing opcode
// 
//  - Outputs:
//     rdy: 	        Asserted when the image coprocessor is not busy
//     done: 	        Asserted for one cycle when the image coprocessor finish processing
//     VGA_R [7:0]: 	R channel, will be tied as {rdata[11:8],4'b0}
//     VGA_G [7:0]: 	G channel, will be tied as {rdata[7:4],4'b0}
//     VGA_B [7:0]: 	B channel, will be tied as {rdata[3:0],4'b0}
//     VGA_BLANK_N: 	Assert (low) during non-active pixels
//     VGA_SYNC_N: 	    Tie it low
//     VGA_VS: 	        Active low vertical synch
//     VGA_HS: 	        Active low horizontal synch
// /////////////////////////////////////////////////////////////////////////////


module coproc(
    input logic clk,
    input logic rst_n,
    input logic VGA_CLK,
    input logic start,
    input logic gray,
    input logic img_idx,
    input logic [2:0] func,
    output logic rdy,
    output logic done,

	output [7:0] VGA_B,
	output [7:0] VGA_G,
	output [7:0] VGA_R,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output VGA_HS,
	output VGA_VS,

    input logic we_boot,
    input logic [3071:0] wdata_boot,
    input logic [8:0] waddr_boot,
    input logic bootloading
);

    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    logic [3071:0] rdata_img_buf, wdata_img_buf;
    logic [35:0] rdata0_out, rdata1_out, rdata2_out;
    logic [11:0] proc_data_out;
    logic [8:0] waddr, raddr;
    logic [2:0] func_reg;
    logic we_pixel, we_img_buf, cnt_start, done_reg, start_reg, gray_reg, img_idx_reg, start_in_reg;

	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////
    VGA_driver iVGA_driver(
        .clk(clk), .rst_n(rst_n), .we(we_pixel), .start(start_reg), .wdata(proc_data_out), .done(done_reg),
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), 
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

    proc_element iDUT (
        .clk(clk), .rst_n(rst_n), .rgb_in0(rdata0_out), .rgb_in1(rdata1_out), .rgb_in2(rdata2_out), 
        .func(func_reg), .gray(gray_reg), .start(start_in_reg), .done(done), .cnt_start(cnt_start), 
        .we_reg(we_pixel), .start_reg(start_reg), .done_reg(done_reg),
        .data_out(proc_data_out));

    image_DMA iImage_DMA(
        .clk(clk), .rst_n(rst_n), .start(start_in_reg), .we_in(we_pixel), .wdata_in(proc_data_out), 
        .rdata_in(rdata_img_buf), .img_idx(img_idx_reg), .raddr(raddr), .waddr(waddr), 
        .we_img_buf(we_img_buf), .wdata_out(wdata_img_buf), .rdata0_out(rdata0_out), .rdata1_out(rdata1_out), 
        .rdata2_out(rdata2_out), .done(done), .rdy_reg(rdy), .cnt_start(cnt_start));

    image_buffer iImage_Buffer(
        .clk(clk), .raddr(raddr), .waddr(waddr), 
        .we(we_img_buf), .wdata(wdata_img_buf), .rdata(rdata_img_buf),
        .we_boot(we_boot), .wdata_boot(wdata_boot), .waddr_boot(waddr_boot), .bootloading(bootloading));

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////
    
    // capture the input control signals for operations
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            gray_reg <= 1'b0;
            img_idx_reg <= 1'b0;
            func_reg <= 3'b000;
            start_in_reg <= 1'b0;
        end
        else if (start) begin
            gray_reg <= gray;
            img_idx_reg <= img_idx;
            func_reg <= func;
            start_in_reg <= 1'b1;
        end
        else begin
            start_in_reg <= 1'b0;
        end
    end

endmodule