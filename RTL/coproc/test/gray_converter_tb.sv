module gray_converter_tb();
    
    // DUT Signals
    logic [11:0] rgb_p0, rgb_p1, rgb_p2, rgb_p3, rgb_p4, rgb_p5, rgb_p6, rgb_p7, rgb_p8;
    logic [11:0] gray_p0, gray_p1, gray_p2, gray_p3, gray_p4, gray_p5, gray_p6, gray_p7, gray_p8;    

    logic [7:0] expected_p0, expected_p1, expected_p2, expected_p3, expected_p4, expected_p5, expected_p6, expected_p7, expected_p8;

    gray_converter iDUT(
        .rgb_in0({rgb_p0, rgb_p1, rgb_p2}), .rgb_in1({rgb_p3, rgb_p4, rgb_p5}),
        .rgb_in2({rgb_p6, rgb_p7, rgb_p8}), .gray_out0({gray_p0, gray_p1, gray_p2}),
        .gray_out1({gray_p3, gray_p4, gray_p5}), .gray_out2({gray_p6, gray_p7, gray_p8}));

    assign expected_p0 = (5*rgb_p0[11:8] + 9*rgb_p0[7:4] + 2*rgb_p0[3:0]);
    assign expected_p1 = (5*rgb_p1[11:8] + 9*rgb_p1[7:4] + 2*rgb_p1[3:0]);
    assign expected_p2 = (5*rgb_p2[11:8] + 9*rgb_p2[7:4] + 2*rgb_p2[3:0]);
    assign expected_p3 = (5*rgb_p3[11:8] + 9*rgb_p3[7:4] + 2*rgb_p3[3:0]);
    assign expected_p4 = (5*rgb_p4[11:8] + 9*rgb_p4[7:4] + 2*rgb_p4[3:0]);
    assign expected_p5 = (5*rgb_p5[11:8] + 9*rgb_p5[7:4] + 2*rgb_p5[3:0]);
    assign expected_p6 = (5*rgb_p6[11:8] + 9*rgb_p6[7:4] + 2*rgb_p6[3:0]);
    assign expected_p7 = (5*rgb_p7[11:8] + 9*rgb_p7[7:4] + 2*rgb_p7[3:0]);
    assign expected_p8 = (5*rgb_p8[11:8] + 9*rgb_p8[7:4] + 2*rgb_p8[3:0]);

    initial begin
        #5;
        for(int i = 0; i < 5'b10000; i++) begin
            for(int j = 0; j < 5'b10000; j++) begin
                for(int k = 0; k < 5'b10000; k++) begin
                    rgb_p0[11:8] = i[3:0];
                    rgb_p1[11:8] = j[3:0];
                    rgb_p2[11:8] = k[3:0];
                    rgb_p3[11:8] = j[3:0];
                    rgb_p4[11:8] = k[3:0];
                    rgb_p5[11:8] = i[3:0];
                    rgb_p6[11:8] = k[3:0];
                    rgb_p7[11:8] = i[3:0];
                    rgb_p8[11:8] = j[3:0];
                    
                    rgb_p0[7:4] = j[3:0];
                    rgb_p1[7:4] = k[3:0];
                    rgb_p2[7:4] = i[3:0];
                    rgb_p3[7:4] = j[3:0];
                    rgb_p4[7:4] = i[3:0];
                    rgb_p5[7:4] = k[3:0];
                    rgb_p6[7:4] = j[3:0];
                    rgb_p7[7:4] = j[3:0];
                    rgb_p8[7:4] = i[3:0];

                    rgb_p0[3:0] = i[3:0];
                    rgb_p1[3:0] = k[3:0];
                    rgb_p2[3:0] = j[3:0];
                    rgb_p3[3:0] = j[3:0];
                    rgb_p4[3:0] = i[3:0];
                    rgb_p5[3:0] = k[3:0];
                    rgb_p6[3:0] = j[3:0];
                    rgb_p7[3:0] = i[3:0];
                    rgb_p8[3:0] = k[3:0];

                    #10;
                    if(gray_p0[7:4] !== expected_p0[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p0[7:4], gray_p0);
                        #10;
                        $stop();
                    end

                    if(gray_p1[7:4] !== expected_p1[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p1[7:4], gray_p1);
                        #10;
                        $stop();
                    end

                    if(gray_p2[7:4] !== expected_p2[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p2[7:4], gray_p2);
                        #10;
                        $stop();
                    end

                    if(gray_p3[7:4] !== expected_p3[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p3[7:4], gray_p3);
                        #10;
                        $stop();
                    end

                    if(gray_p4[7:4] !== expected_p4[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p4[7:4], gray_p4);
                        #10;
                        $stop();
                    end

                    if(gray_p5[7:4] !== expected_p5[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p5[7:4], gray_p5);
                        #10;
                        $stop();
                    end

                    if(gray_p6[7:4] !== expected_p6[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p6[7:4], gray_p6);
                        #10;
                        $stop();
                    end

                    if(gray_p7[7:4] !== expected_p7[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p7[7:4], gray_p7);
                        #10;
                        $stop();
                    end

                    if(gray_p8[7:4] !== expected_p8[7:4]) begin
                        $display("Value incorrect: expected: %h, actual: %h\n", expected_p8[7:4], gray_p8);
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