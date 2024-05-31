module data_accum_tb();

    // DUT Signals
    logic clk, rst_n, we_in, start;
    logic [7:0] col_cnt;
    logic [11:0] wdata_in;
    logic [3071:0] wdata_out;

    // Instantiate data accumulation module
    data_accum idata_accum(
        .clk(clk), .rst_n(rst_n), .we_in(we_in), .start(start),
        .col_cnt(col_cnt), .wdata_in(wdata_in), .wdata_out(wdata_out));

    always #5 clk = ~clk;

    always_ff @(negedge clk, negedge rst_n) begin
        if(~rst_n)
            col_cnt <= '0;
        else if(start)
            col_cnt <= '0;
        else
            col_cnt <= col_cnt + 1;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n)
            wdata_in <= '0;
        else if(start)
            wdata_in <= '0;
        else
            wdata_in <= wdata_in + 1;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        we_in = 0;

        @(negedge clk);
        rst_n = 1;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;
        we_in = 1;


        repeat(256) @(posedge clk);

        repeat(10) @(posedge clk);

        repeat(256) @(posedge clk);

        repeat(10) @(posedge clk);

        $stop();

    end
    

endmodule