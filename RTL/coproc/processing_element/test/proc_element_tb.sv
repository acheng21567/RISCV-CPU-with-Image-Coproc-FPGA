module proc_element_tb();
    logic clk, rst_n;
    logic [35:0] rgb_in0, rgb_in1, rgb_in2;
    logic [2:0] func;
    logic gray;
    logic start;
    logic rdy;
    logic we;
    logic [11:0] data_out;

    always #5 clk = ~clk;

    proc_element iDUT (
        .clk(clk), 
        .rst_n(rst_n), 
        .rgb_in0(rgb_in0), 
        .rgb_in1(rgb_in1), 
        .rgb_in2(rgb_in2), 
        .func(func), 
        .gray(gray), 
        .start(start), 
        .rdy(rdy), 
        .we(we), 
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        rst_n = 1;
        rgb_in0 = 36'h000111222;
        rgb_in1 = 36'h333444555;
        rgb_in2 = 36'h666777888;
        func = 3'b111;
        gray = 0;
        start = 0;
        
        @(negedge clk);
        rst_n = 0;

        @(negedge clk);
        rst_n = 1;

        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        repeat(100000) @(posedge clk);

        $stop();


    end


endmodule