module VGA_driver_tb();

    logic clk, rst_n, we, start, img_idx;
    logic [11:0] wdata;
    logic VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;
    logic [7:0] VGA_R, VGA_G, VGA_B;

    VGA_driver iVGA_driver(
        .clk(clk), .rst_n(rst_n), .we(we), .start(start), .img_idx(img_idx), .wdata(wdata), .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

    always #5 clk = ~clk;
    always #10 VGA_CLK = ~VGA_CLK;

    logic [11:0] data_write;



    initial begin
        clk = 0;
        VGA_CLK = 0;
        rst_n = 0;
        we = 0;
        start = 0;
        img_idx = 0;
        wdata = 0;
        data_write = 12'h000;

        @(negedge clk);
        rst_n = 1;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        we = 1;
        wdata = data_write;


        @(negedge clk);
        start = 0;

        data_write = data_write + 1;
        wdata = data_write;

        repeat(1000) begin
            @(negedge clk);
            data_write = data_write + 1;
            wdata = data_write;
        end


        $stop();


    end

endmodule