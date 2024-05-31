module image_buffer_tb();

    // DUT Signals
    logic clk, rst_n;
    logic [6:0] raddr0, raddr1, raddr2;
    logic [8:0] waddr;
    logic re, we, img_idx;
    logic [3071:0] wdata, rdata0, rdata1, rdata2;

    logic start;

    image_buffer iTest_Buffer(
        .clk(clk), .rst_n(rst_n), .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2),
        .waddr(waddr), .re(re), .we(we), .img_idx(img_idx), .wdata(wdata),
        .rdata0(rdata0), .rdata1(rdata1), .rdata2(rdata2));

    always #5 clk = ~clk;


    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            raddr0 <= 7'b00;
            raddr1 <= 7'b00;
            raddr2 <= 7'b00;
        end
        else if(start) begin
            raddr0 <= 7'b01;
            raddr1 <= 7'b01;
            raddr2 <= 7'b01;
        end

    end

    initial begin
        start = 0;
        clk = 0;
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;
        
        img_idx = 1;
        @(posedge clk);
        start = 1;
        re = 1;

        @(negedge clk);
        
        we = 1;
        waddr = 9'h001;
        wdata = '1;

        @(posedge clk);
        start = 0;
        re = 0;

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

        @(negedge clk);
        re = 1;
        img_idx = 0;

        repeat(10) @(negedge clk);
        $stop();
    end

endmodule