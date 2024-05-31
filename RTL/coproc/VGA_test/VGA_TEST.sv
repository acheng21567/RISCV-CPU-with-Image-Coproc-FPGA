module VGA_TEST(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

    logic clk, rst_n, we, start, img_idx, pll_locked;
    logic [11:0] wdata;

    PLL iPLL(.refclk(CLOCK_50), .rst(~KEY[0]),.outclk_0(clk),.outclk_1(VGA_CLK),
           .locked(pll_locked));
 
    rst_synch iRST(.clk(clk),.RST_n(KEY[0]), .pll_locked(pll_locked), .rst_n(rst_n));

    // assign rst_n = KEY[0];
    // assign clk = CLOCK_50;

    VGA_driver iVGA_driver(
        .clk(clk), .rst_n(rst_n), .we(1'b1), .start(start), .img_idx(1'b0), .wdata(wdata), .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK_N(VGA_BLANK_N), .VGA_SYNC_N(VGA_SYNC_N), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B));

    logic [11:0] rom[0:65535];

    logic [15:0] addr;

    assign start = ~KEY[1];

    initial
        $readmemh("I:\\win\\desktop\\ECE554\\VGA_TEST\\Miku.hex",rom);

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            addr <= '0;
        end 
        else if (start) begin
            addr <= '0;
        end
        else begin
            addr <= addr + 1;
        end
    end

    always @(posedge clk)
        wdata <= rom[addr];

endmodule