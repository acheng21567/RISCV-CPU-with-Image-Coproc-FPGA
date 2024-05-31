module VGA_driver(
    input logic clk,
    input logic rst_n,
    input logic we,
    input logic start,
    input logic [11:0] wdata,
    input logic done,
    input logic VGA_CLK,

    output logic VGA_HS,
    output logic VGA_VS,
    output logic VGA_BLANK_N,
    output logic VGA_SYNC_N,
    output logic [7:0] VGA_R,
    output logic [7:0] VGA_G,
    output logic [7:0] VGA_B
);

    logic [16:0] waddr, raddr_mem;
    logic [18:0] raddr;

    logic [11:0] rdata, rdata_mem;

    logic [9:0] xpix;
    logic [8:0] ypix;

    logic we_out;

    VGA_timing iVGATM(.clk25MHz(VGA_CLK), .rst_n(rst_n), .VGA_BLANK_N(VGA_BLANK_N), 
                      .VGA_HS(VGA_HS),.VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), 
                      .xpix(xpix), .ypix(ypix), .addr_lead(raddr));

    VGA_DMA VGA_DMA(.clk(clk), .rst_n(rst_n), .we_in(we), .start(start), .done(done), .waddr(waddr), .we_out(we_out));

    video_mem video_mem(.clk(clk),.we(we_out),.waddr(waddr),.wdata(wdata),.raddr(raddr_mem),.rdata(rdata_mem));

    assign raddr_mem = raddr - ypix * (640-512);
    assign rdata = ypix > 255 ? '0 : (xpix[9] ? '0 : rdata_mem);
    assign VGA_R = {rdata[11:8], 4'b0};
    assign VGA_G = {rdata[7:4], 4'b0};
    assign VGA_B = {rdata[3:0], 4'b0};


endmodule