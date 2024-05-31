module rgb2gray(
    input logic [11:0] rgb_in,
    output logic [11:0] gray_out
);
    logic [7:0] gray;
    // gray = (5 * R + 9 * G + 2 * B) / 16
    assign gray = (((rgb_in[11:8] << 2) + rgb_in[11:8]) + 
                      ((rgb_in[7:4] << 3) + rgb_in[7:4]) +
                      (rgb_in[3:0] << 1));
    assign gray_out = {3{gray[7:4]}};
endmodule