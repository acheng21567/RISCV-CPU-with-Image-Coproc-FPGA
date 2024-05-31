module VGA_TEST_tb();

logic clk;
always #5 clk = ~clk;

logic [3:0] KEY;

VGA_TEST VGA_DUT(.CLOCK_50(clk), .KEY(KEY));

initial begin
    KEY = '1;
    clk = 0;

    @(negedge clk);
    KEY[0] = 0;

    @(negedge clk);
    KEY[0] = 1;

    @(negedge clk);
    KEY[1] = 0;

    repeat(100) @(negedge clk);
    KEY[1] = 1;

    repeat(100000) @(posedge clk);
    $stop();
end

endmodule