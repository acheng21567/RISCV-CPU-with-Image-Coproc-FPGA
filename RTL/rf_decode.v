`default_nettype none
module rf_decode (
    input wire [4:0] rd,
    input wire reg_write,
    output wire [31:0] write_dec
);
    // generate 32 writeEn signals specified by rd using assign
    assign write_dec[0] = 1'b0;
    assign write_dec[1] = rd == 5'b00001 ? reg_write : 1'b0;
    assign write_dec[2] = rd == 5'b00010 ? reg_write : 1'b0;
    assign write_dec[3] = rd == 5'b00011 ? reg_write : 1'b0;
    assign write_dec[4] = rd == 5'b00100 ? reg_write : 1'b0;
    assign write_dec[5] = rd == 5'b00101 ? reg_write : 1'b0;
    assign write_dec[6] = rd == 5'b00110 ? reg_write : 1'b0;
    assign write_dec[7] = rd == 5'b00111 ? reg_write : 1'b0;
    assign write_dec[8] = rd == 5'b01000 ? reg_write : 1'b0;
    assign write_dec[9] = rd == 5'b01001 ? reg_write : 1'b0;
    assign write_dec[10] = rd == 5'b01010 ? reg_write : 1'b0;
    assign write_dec[11] = rd == 5'b01011 ? reg_write : 1'b0;
    assign write_dec[12] = rd == 5'b01100 ? reg_write : 1'b0;
    assign write_dec[13] = rd == 5'b01101 ? reg_write : 1'b0;
    assign write_dec[14] = rd == 5'b01110 ? reg_write : 1'b0;
    assign write_dec[15] = rd == 5'b01111 ? reg_write : 1'b0;
    assign write_dec[16] = rd == 5'b10000 ? reg_write : 1'b0;
    assign write_dec[17] = rd == 5'b10001 ? reg_write : 1'b0;
    assign write_dec[18] = rd == 5'b10010 ? reg_write : 1'b0;
    assign write_dec[19] = rd == 5'b10011 ? reg_write : 1'b0;
    assign write_dec[20] = rd == 5'b10100 ? reg_write : 1'b0;
    assign write_dec[21] = rd == 5'b10101 ? reg_write : 1'b0;
    assign write_dec[22] = rd == 5'b10110 ? reg_write : 1'b0;
    assign write_dec[23] = rd == 5'b10111 ? reg_write : 1'b0;
    assign write_dec[24] = rd == 5'b11000 ? reg_write : 1'b0;
    assign write_dec[25] = rd == 5'b11001 ? reg_write : 1'b0;
    assign write_dec[26] = rd == 5'b11010 ? reg_write : 1'b0;
    assign write_dec[27] = rd == 5'b11011 ? reg_write : 1'b0;
    assign write_dec[28] = rd == 5'b11100 ? reg_write : 1'b0;
    assign write_dec[29] = rd == 5'b11101 ? reg_write : 1'b0;
    assign write_dec[30] = rd == 5'b11110 ? reg_write : 1'b0;
    assign write_dec[31] = rd == 5'b11111 ? reg_write : 1'b0;

endmodule
`default_nettype wire