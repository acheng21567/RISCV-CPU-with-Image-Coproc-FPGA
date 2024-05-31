module image_buffer(
    input logic clk,
    input logic rst_n,
    input logic [6:0] raddr0,
    input logic [6:0] raddr1,
    input logic [6:0] raddr2,
    input logic [8:0] waddr,
    input logic re,
    input logic we,
    input logic img_idx,
    input logic [3071:0] wdata,
    output logic [3071:0] rdata0,
    output logic [3071:0] rdata1,
    output logic [3071:0] rdata2
);

    logic [3071:0] rdata0_orig, rdata1_orig, rdata2_orig;
    logic [3071:0] rdata0_recent, rdata1_recent, rdata2_recent;

    image_container #(.LOAD_MEM(1))
    original_image (
        .clk(clk),
        .rst_n(rst_n),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .re(re),
        .we(1'b0),
        .rdata0(rdata0_orig),   
        .rdata1(rdata1_orig),
        .rdata2(rdata2_orig),
        .wdata(wdata)
    );

    image_container #(.LOAD_MEM(0))
    recent_image (
        .clk(clk),
        .rst_n(rst_n),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .re(re),
        .we(we),
        .rdata0(rdata0_recent),
        .rdata1(rdata1_recent),
        .rdata2(rdata2_recent),
        .wdata(wdata)
    );

    assign rdata0 = img_idx ? rdata0_recent : rdata0_orig;
    assign rdata1 = img_idx ? rdata1_recent : rdata1_orig;
    assign rdata2 = img_idx ? rdata2_recent : rdata2_orig;

endmodule