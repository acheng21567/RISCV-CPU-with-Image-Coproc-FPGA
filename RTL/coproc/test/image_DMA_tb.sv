module image_DMA_tb();

    // DMA Signals
    logic clk, rst_n, start, img_idx_in, we_in;
    logic [11:0] wdata_in;
    logic [3071:0] rdata0_in, rdata1_in, rdata2_in;

    logic [6:0] raddr0, raddr1, raddr2;
    logic [8:0] waddr;
    logic re, we_out, img_idx_out;
    logic [3071:0] wdata_out;
    logic [35:0] rdata0_out, rdata1_out, rdata2_out;

    img_DMA iImg_DMA(
        .clk(clk), .rst_n(rst_n), .start(start), .we_in(we_in),
        .wdata_in(wdata_in), .rdata0_in(rdata0_in), .rdata1_in(rdata1_in), .rdata2_in(rdata2_in),
        .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2), .waddr(waddr), .re(re), .we_out(we_out),
        .wdata_out(wdata_out), .rdata0_out(rdata0_out),
        .rdata1_out(rdata1_out), .rdata2_out(rdata2_out));

    image_buffer iImage_Buffer(
        .clk(clk), .rst_n(rst_n), .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2), .waddr(waddr),
        .re(re), .we(we_out), .img_idx(img_idx_out), .wdata(wdata_out), .rdata0(rdata0_in), .rdata1(rdata1_in), .rdata2(rdata2_in));

    always #5 clk = ~clk;

    assign wdata_in = ~rdata1_out[23:12];

    initial begin
        img_idx_out = 0;
        clk = 0;
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;
        img_idx_in = 0;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;
        we_in = 1;

        repeat(256*256) @(negedge clk);

        repeat(100) @(negedge clk);
        $stop();


    end

endmodule