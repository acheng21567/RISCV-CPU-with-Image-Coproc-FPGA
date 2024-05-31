module basic_ALU(
    input logic [11:0] pixel_in,
    input logic [1:0] func,
    output logic [11:0] pixel_out
);
    localparam THRESH = 4'b0110;
    localparam MAX = 4'b1111;
    localparam MIN = 4'b0000;

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
            color = 12'hF9C;
        else
            color = 12'hF00;
    end

    // 1.5 * (val - 4'b1000) + 4'b1000 for each channel
    // logic signed [11:0] r, g, b, r_contrast, g_contrast, b_contrast;
    // assign r = {8'b0, pixel_in[11:8]};
    // assign g = {8'b0, pixel_in[7:4]};
    // assign b = {8'b0, pixel_in[3:0]};
    // assign r_contrast = (((r - 12'h08) * 6) >> 2) + 12'h08;
    // assign g_contrast = (((g - 12'h08) * 6) >> 2) + 12'h08;
    // assign b_contrast = (((b - 12'h08) * 6) >> 2) + 12'h08;


    // assign contrast = {
    //     r_contrast > 12'h0F ? 4'hF : (r_contrast < 12'h00 ? 4'h0 : r_contrast[3:0]),
    //     g_contrast > 12'h0F ? 4'hF : (g_contrast < 12'h00 ? 4'h0 : g_contrast[3:0]),
    //     b_contrast > 12'h0F ? 4'hF : (b_contrast < 12'h00 ? 4'h0 : b_contrast[3:0])
    // };

    logic signed [11:0] r, g, b;
    logic signed [11:0] r_contrast, g_contrast, b_contrast;

    // Extend 4-bit inputs to 8-bit signed values for more range in calculations
    assign r = {4'b0, pixel_in[11:8], 4'b0};  // Moving the bits to a higher range
    assign g = {4'b0, pixel_in[7:4], 4'b0};
    assign b = {4'b0, pixel_in[3:0], 4'b0};

    // Apply contrast by emphasizing deviation from the midpoint
    assign r_contrast = (((r - 12'h080) * 3) >> 1) + 12'h080;
    assign g_contrast = (((g - 12'h080) * 3) >> 1) + 12'h080;
    assign b_contrast = (((b - 12'h080) * 3) >> 1) + 12'h080;

    // Clamping results to 8-bit values and reducing back to 4-bit
    assign contrast = {
        (r_contrast > $signed(12'h0FF) ? MAX : (r_contrast < $signed(12'h010) ? MIN : r_contrast[7:4])),
        (g_contrast > $signed(12'h0FF) ? MAX : (g_contrast < $signed(12'h010) ? MIN : g_contrast[7:4])),
        (b_contrast > $signed(12'h0FF) ? MAX : (b_contrast < $signed(12'h010) ? MIN : b_contrast[7:4]))
    };

    assign thresh = {
        pixel_in[11:8] > THRESH ? MAX : MIN,
        pixel_in[7:4]  > THRESH ? MAX : MIN,
        pixel_in[3:0]  > THRESH ? MAX : MIN
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