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

    logic [3071:0] rdata_img_buf, wdata_img_buf;
    logic [35:0] rdata0_out, rdata1_out, rdata2_out;
    logic [11:0] proc_data_out;
    logic [8:0] waddr;
    logic [8:0] raddr;
    logic we_pixel, we_img_buf;
    logic cnt_start;
    logic done_reg, start_reg;


    VGA_driver iVGA_driver(
        .clk(clk), .rst_n(rst_n), .we(we_pixel), .start(start_reg), .wdata(proc_data_out), .done(done_reg),
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), 
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

    proc_element iDUT (
        .clk(clk), .rst_n(rst_n), .rgb_in0(rdata0_out), .rgb_in1(rdata1_out), .rgb_in2(rdata2_out), 
        .func(func), .gray(gray), .start(start), .done(done), .cnt_start(cnt_start), 
        .we_reg(we_pixel), .start_reg(start_reg), .done_reg(done_reg),
        .data_out(proc_data_out));

    image_DMA iImage_DMA(
        .clk(clk), .rst_n(rst_n), .start(start), .we_in(we_pixel), .wdata_in(proc_data_out), 
        .rdata_in(rdata_img_buf), .img_idx(img_idx), .raddr(raddr), .waddr(waddr), 
        .we_img_buf(we_img_buf), .wdata_out(wdata_img_buf), .rdata0_out(rdata0_out), .rdata1_out(rdata1_out), 
        .rdata2_out(rdata2_out), .done(done), .rdy_reg(rdy), .cnt_start(cnt_start));

    image_buffer iImage_Buffer(
        .clk(clk), .raddr(raddr), .waddr(waddr), 
        .we(we_img_buf), .wdata(wdata_img_buf), .rdata(rdata_img_buf),
        .we_boot(we_boot), .wdata_data(wdata_boot), .wdata_addr(waddr_boot), .bootloading(bootloading));
endmodule