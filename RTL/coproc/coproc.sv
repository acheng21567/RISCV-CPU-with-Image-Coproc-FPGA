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
	output VGA_VS
);

    logic [3071:0] rdata0_in, rdata1_in, rdata2_in, img_buf_wdata;
    logic [35:0] rdata0_out, rdata1_out, rdata2_out;
    logic [11:0] proc_data_out;
    logic [8:0] waddr;
    logic [6:0] raddr0, raddr1, raddr2;
    logic pixel_we, img_buf_we, re;

    proc_element iDUT (
        .clk(clk), .rst_n(rst_n), .rgb_in0(rdata0_out), .rgb_in1(rdata1_out), .rgb_in2(rdata2_out), 
        .func(func), .gray(gray), .start(start), .rdy(rdy), .we(pixel_we), .data_out(proc_data_out), .done(done));

    VGA_driver iVGA_driver(
        .clk(clk), .rst_n(rst_n), .we(pixel_we), .start(start), .img_idx(img_idx), .wdata(proc_data_out), 
        .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), 
        .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

    img_DMA iImg_DMA(
        .clk(clk), .rst_n(rst_n), .start(start), .we_in(pixel_we),
        .wdata_in(proc_data_out), .rdata0_in(rdata0_in), .rdata1_in(rdata1_in), .rdata2_in(rdata2_in),
        .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2), .waddr(waddr), .re(re), .we_out(img_buf_we),
        .wdata_out(img_buf_wdata), .rdata0_out(rdata0_out), .rdata1_out(rdata1_out), .rdata2_out(rdata2_out));

    image_buffer iImage_Buffer(
        .clk(clk), .rst_n(rst_n), .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2), .waddr(waddr), .re(re & ~rdy), 
        .we(img_buf_we & ~rdy), .img_idx(img_idx), .wdata(img_buf_wdata), .rdata0(rdata0_in), .rdata1(rdata1_in), .rdata2(rdata2_in));

endmodule