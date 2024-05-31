module addr_calc_DMA_tb();

    // DUT Signals
    logic clk, rst_n, start, we_in, re, we_out;
    logic [6:0] raddr0, raddr1, raddr2;
    logic [8:0] waddr;
    logic [7:0] col_cnt;
    logic [2:0] row_sel_onehot;


    // Instantiate address calculation module
    addr_calc_DMA iAddr_Cal_DMA(
        .clk(clk), .rst_n(rst_n), .start(start), .we_in(we_in), .re(re),
        .we_out(we_out), .raddr0(raddr0), .raddr1(raddr1), .raddr2(raddr2),
        .waddr(waddr), .col_cnt(col_cnt), .row_sel_onehot(row_sel_onehot));

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;
        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        @(negedge clk);
        we_in = 1;

        repeat(256*256) @(negedge clk);
        
        repeat(10) @(negedge clk);

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        @(negedge clk);
        we_in = 1;

        repeat(256*256) @(negedge clk);
        
        repeat(10) @(negedge clk);

        $stop();

    end
endmodule