module gray_converter(
    input logic [35:0] rgb_in0,
    input logic [35:0] rgb_in1,
    input logic [35:0] rgb_in2,
    output logic [35:0] gray_out0,
    output logic [35:0] gray_out1,
    output logic [35:0] gray_out2
);
    rgb2gray rgb2gray0[8:0](
        {rgb_in0, rgb_in1, rgb_in2}, 
        {gray_out0, gray_out1, gray_out2}); 

endmodule