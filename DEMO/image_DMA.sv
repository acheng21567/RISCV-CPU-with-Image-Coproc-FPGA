// /////////////////////////////////////////////////////////////////////////////
// Program: image_DMA.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Image DMA top level module that reads image data from the image buffer and sends it to the processing element, and writes processed image data back to the image buffer
// 
//  - Inputs:
//     clk: 	            Global clock signal for 25MHz
//     rst_n: 	            Global active low reset
//     start: 	            Start signal asserted from the host processor to initiate the image processing
//     we_in: 	            Write enable for writing and shifting 12-bit wdata_in into the shift register in data_accum
//     wdata_in [11:0]: 	12-bit input write data to be written into the shift register
//     rdata_in [3071:0]: 	3072-bit read data from image buffer, will be stored in the register
//     img_idx: 	        Image index from the host processor, 0 represents the original image and 1 represents the most recent image stored in image buffer
// 
//  - Outputs:
//     raddr [8:0]: 	    9-bit read address to read from the image buffer, concatenate img_idx at the MSB with raddr [7:0] from addr_cal
//     waddr [8:0]: 	    9-bit write address to write into the image buffer
//     we_img_buf: 	        Write enable for writing to image buffer
//     wdata_out [3071:0]: 	3072-bit write data to be written into image buffer
//     rdata0_out [35:0]: 	First row of data for a 3*3 convolution window, sending to proc_element for further calculation
//     rdata1_out [35:0]: 	Second row of data for a 3*3 convolution window, sending to proc_element for further calculation
//     rdata2_out [35:0]: 	Third row of data for a 3*3 convolution window, sending to proc_element for further calculation
//     done: 	            Done signal asserted for one cycle, showing the completion of image processing
//     rdy_reg: 	        Ready signal asserted when image processor is not in processing state, pipelined from rdy in addr_cal_DMA
//     cnt_start: 	        Asserted to set write enable for VGA_driver
// /////////////////////////////////////////////////////////////////////////////

module image_DMA(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic we_in,
    input logic [11:0] wdata_in,
    input logic [3071:0] rdata_in,
    input logic img_idx,

    output logic [8:0] raddr,
    output logic [8:0] waddr,
    output logic we_img_buf,
    output logic [3071:0] wdata_out,
    output logic [35:0] rdata0_out,
    output logic [35:0] rdata1_out,
    output logic [35:0] rdata2_out,
    output logic done,
    output logic rdy_reg,
    output logic cnt_start
);
    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    logic [3071:0] r0, r1, r2;  
    logic [7:0] col_cnt, raddr_img;
    logic [2:0] reg_sel;
    logic reg2_rst, re, rdy;

	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////
    data_accum data_accum(
        .clk(clk),
        .rst_n(rst_n),
        .we_in(we_in),
        .wdata_in(wdata_in),
        .wdata_out(wdata_out)
    );

    addr_calc_DMA addr_calc_DMA(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .we_img_buf(we_img_buf),
        .raddr(raddr_img),
        .waddr(waddr),
        .col_cnt(col_cnt),
        .reg_sel(reg_sel),
        .done(done),
        .rdy(rdy),
        .reg2_rst(reg2_rst),
        .cnt_start(cnt_start),
        .re(re)
    );

    pixel_sel pixel_sel(
        .rdata0_in(r0),
        .rdata1_in(r1),
        .rdata2_in(r2),
        .col_cnt(col_cnt),
        .reg_sel(reg_sel),
        .rdata0_out(rdata0_out),
        .rdata1_out(rdata1_out),
        .rdata2_out(rdata2_out)
    );

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // flop the ready signal to align with the pipeline in proc_element
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            rdy_reg <= 0;
        end
        else begin
            rdy_reg <= rdy;
        end
    end

    // store rows of pixels into three registers for pixel selection
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            r0 <= '0;
        end
        else if (start) begin
            r0 <= '0;
        end
        // r0 will be 0 when operating on the first row of the image (simulate the top padding)
        else if (re & reg_sel[0]) begin
            r0 <= rdata_in;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            r1 <= '0;
        end
        // r1 will never be empty
        else if (re & reg_sel[1]) begin
            r1 <= rdata_in;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            r2 <= '0;
        end
        else if (reg2_rst) begin
            r2 <= '0;
        end
        // r2 will be 0 when operating on the last row of the image (simulate the bottom padding)
        else if (re & reg_sel[2]) begin
            r2 <= rdata_in;
        end
    end

    // assign the image buffer read address to choose between the original image and the recent image 
    assign raddr = {img_idx, raddr_img};

endmodule