module rgb2gray_tb();
    
    // DUT Signals
    logic [4:0] r_in, b_in, g_in;
    logic [7:0] place_holder;
    logic [3:0] gray_out;

    logic [7:0] expected;

    rgb2gray iRGB2GRAY(
        .rgb_in({r_in[3:0], g_in[3:0], b_in[3:0]}),
        .gray_out({place_holder,gray_out}));

    assign expected = (5 * r_in + 9 * g_in + 2 * b_in);

    initial begin
        #5;
        for(r_in = 0; r_in < 5'b10000; r_in++) begin
            for(g_in = 0; g_in < 5'b10000; g_in++) begin
                for(b_in = 0; b_in < 5'b10000; b_in++) begin
                    #10;
                    if(gray_out !== expected[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected[7:4], gray_out);
                        #10;
                        $stop();
                    end
                end
            end
        end
        #5;
        $stop();
    end

endmodule