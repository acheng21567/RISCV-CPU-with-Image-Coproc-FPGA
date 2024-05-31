module coproc_tb();

    logic rdy, done;
    logic clk, VGA_CLK, start, rst_n;
    logic [7:0] VGA_B, VGA_G, VGA_R;
    logic [11:0] output_pix;
    logic gray, img_idx;
    logic [2:0] func;

    // PLL iPLL(.refclk(CLOCK_50), .rst(~KEY[0]),.outclk_0(clk),.outclk_1(VGA_CLK),
    //         .locked(pll_locked));
    
    // rst_synch iRST(.clk(clk),.RST_n(KEY[0]), .pll_locked(pll_locked), .rst_n(rst_n));

    coproc iCOPROC(
        .clk(clk), .rst_n(rst_n), .VGA_CLK(VGA_CLK), .start(start), .gray(gray), .img_idx(img_idx), 
        .func(func), .rdy(rdy), .VGA_B(VGA_B), .VGA_G(VGA_G), .VGA_R(VGA_R), .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .done(done));

    assign output_pix = {VGA_R[7:4], VGA_G[7:4], VGA_B[7:4]};

    always #5 clk = ~clk;
    always #10 VGA_CLK = VGA_CLK;

    initial begin
        clk = 0;
        VGA_CLK = 0;

        rst_n = 1;
        func = 3'b111;
        gray = 0;
        img_idx = 0;
        start = 0;
        
        @(negedge clk);
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        repeat(70000) @(posedge clk);

        @(negedge clk);
        func = 3'b010;
        gray = 0;
        img_idx = 1;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        repeat(70000) @(posedge clk);

        @(negedge clk);
        func = 3'b110;
        gray = 1;
        img_idx = 1;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        repeat(70000) @(posedge clk);
        
        // @(negedge clk);
        // func = 3'b011;
        // gray = 0;
        // img_idx = 1;

        // @(posedge clk);
        // start = 1;

        // @(posedge clk);
        // start = 0;

        // repeat(70000) @(posedge clk);

        $stop();


    end
endmodule