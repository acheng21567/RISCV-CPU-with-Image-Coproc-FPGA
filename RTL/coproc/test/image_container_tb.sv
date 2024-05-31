module image_container_tb();

    // DUT Signals
    logic clk, rst_n;
    logic [6:0] raddr0, raddr1, raddr2;
    logic [8:0] waddr;
    logic re, we;
    logic [3071:0] wdata, rdata0, rdata1, rdata2;

    // Instantiate image bank
    image_container iTest_Container(
        .clk(clk), .rst_n(rst_n), .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2),
        .waddr(waddr), .re(re), .we(we), .wdata(wdata),
        .rdata0(rdata0), .rdata1(rdata1), .rdata2(rdata2));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;
        re = 1;
        raddr0 = 7'h01;
        raddr1 = 7'h01;
        raddr2 = 7'h01;

        @(negedge clk);
        re = 0;
        we = 1;
        waddr = 9'h001;
        wdata = '1;

        @(negedge clk);
        we = 0;
        re = 1;

        @(negedge clk);
        re = 0;
        we = 1;
        waddr = 9'h081;
        wdata = '1;

        @(negedge clk);
        we = 0;
        re = 1;

        @(negedge clk);
        re = 0;
        we = 1;
        waddr = 9'h101;
        wdata = '1;

        @(negedge clk);
        we = 0;
        re = 1;

        repeat(10) @(negedge clk);
        $stop();
    end

endmodule