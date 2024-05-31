module basic_ALU(
    input logic [11:0] pixel_in,
    input logic [1:0] func,
    input logic [11:0] max,
    input logic [11:0] min,
    output logic [11:0] pixel_out
);
    logic [11:0] invert, color, contrast, thresh;

    assign invert = ~pixel_in;

    always_comb begin
        if (pixel_in[7:4] <= 4'b0010)
            color = '0;
        else if (pixel_in[7:4] <= 4'b0100)
            color = 12'h00F;
        else if (pixel_in[7:4] <= 4'b1001)
            color = 12'h0F0;
        else if (pixel_in[7:4] <= 4'b1101)
            color = 12'hF00;
        else
            color = '1;
    end

    assign contrast = {
        (pixel_in[11:8] - min[11:8]) / (max[11:8] - min[11:8]) * 7,
        (pixel_in[7:4] - min[7:4])   / (max[7:4]  - min[7:4])  * 7,
        (pixel_in[3:0] - min[3:0])   / (max[3:0]  - min[3:0])  * 7
    };

    assign thresh = {
        pixel_in[11:8] > 4'b0111 ? 4'b1111 : 4'b0000,
        pixel_in[7:4]  > 4'b0111 ? 4'b1111 : 4'b0000,
        pixel_in[3:0]  > 4'b0111 ? 4'b1111 : 4'b0000
    };

    always_comb begin
        case (func)
            2'b00: pixel_out = invert;
            2'b01: pixel_out = color;
            2'b10: pixel_out = contrast;
            default: pixel_out = thresh;
        endcase
    end

endmodule