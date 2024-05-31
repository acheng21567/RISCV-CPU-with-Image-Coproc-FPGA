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

    logic [7:0] col_cnt;
    logic [2:0] reg_sel;
    logic [3071:0] r0, r1, r2;  
    logic reg2_rst, re;
    logic [7:0] raddr_img;
    logic rdy;

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            rdy_reg <= 0;
        end
        else begin
            rdy_reg <= rdy;
        end
    end

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

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            r0 <= '0;
        end
        else if (start) begin
            r0 <= '0;
        end
        else if (re & reg_sel[0]) begin
            r0 <= rdata_in;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            r1 <= '0;
        end
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
        else if (re & reg_sel[2]) begin
            r2 <= rdata_in;
        end
    end

    assign raddr = {img_idx, raddr_img};

endmodule