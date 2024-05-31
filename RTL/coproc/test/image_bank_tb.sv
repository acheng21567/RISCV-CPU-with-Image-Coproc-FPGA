module image_bank_tb();

    // DUT Signals
    logic clk, rst_n;
    logic [6:0] raddr, waddr;
    logic re, we;
    logic [3071:0] wdata, rdata;


    // Instantiate image bank
    image_bank iTest_bank(.clk(clk), .rst_n(rst_n), .raddr(raddr), .waddr(waddr),
                          .re(re), .we(we), .wdata(wdata), .rdata(rdata));

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;
        re = 1;
        raddr = 7'h01;

        @(negedge clk);
        re = 0;
        we = 1;
        waddr = 7'h01;
        wdata = '1;

        @(negedge clk);
        we = 0;
        re = 1;

        repeat(10) @(negedge clk);
        $stop();
    end

endmodule