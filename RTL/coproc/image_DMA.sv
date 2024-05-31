module img_DMA(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic we_in,
    input logic [11:0] wdata_in,
    input logic [3071:0] rdata0_in,
    input logic [3071:0] rdata1_in,
    input logic [3071:0] rdata2_in,

    output logic [6:0] raddr0,
    output logic [6:0] raddr1,
    output logic [6:0] raddr2,
    output logic [8:0] waddr,
    output logic re,
    output logic we_out,
    output logic [3071:0] wdata_out,
    output logic [35:0] rdata0_out,
    output logic [35:0] rdata1_out,
    output logic [35:0] rdata2_out
);

    logic [7:0] col_cnt;
    logic [2:0] row_sel_onehot;

    data_accum data_accum(
        .clk(clk),
        .rst_n(rst_n),
        .we_in(we_in),
        .start(start),
        .wdata_in(wdata_in),
        .col_cnt(col_cnt),
        .wdata_out(wdata_out)
    );

    addr_calc_DMA addr_calc_DMA(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .re(re),
        .we_in(we_in),
        .we_out(we_out),
        .raddr0(raddr0),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .col_cnt(col_cnt),
        .row_sel_onehot(row_sel_onehot)
    );

    pixel_sel pixel_sel(
        .rdata0_in(rdata0_in),
        .rdata1_in(rdata1_in),
        .rdata2_in(rdata2_in),
        .col_cnt(col_cnt),
        .row_sel_onehot(row_sel_onehot),
        .rdata0_out(rdata0_out),
        .rdata1_out(rdata1_out),
        .rdata2_out(rdata2_out)
    );

endmodule