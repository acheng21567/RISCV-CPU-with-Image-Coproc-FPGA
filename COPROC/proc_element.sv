module proc_element(
    input logic clk,
    input logic rst_n,
    input logic [35:0] rgb_in0,
    input logic [35:0] rgb_in1,
    input logic [35:0] rgb_in2,
    input logic [2:0] func,
    input logic gray,
    input logic start,
    input logic cnt_start,
    input logic done,
    output logic we_reg,
    output logic start_reg,
    output logic done_reg,
    output logic [11:0] data_out
);
    logic [35:0] gray_in0, gray_in1, gray_in2;
    logic [35:0] pixel_in0, pixel_in1, pixel_in2;
    logic [11:0] basic_ALU_out, conv_out;
    logic prev_rdy;

    gray_converter gray_converter0(
        .rgb_in0(rgb_in0),
        .rgb_in1(rgb_in1),
        .rgb_in2(rgb_in2),
        .gray_out0(gray_in0),
        .gray_out1(gray_in1),
        .gray_out2(gray_in2)
    );

    assign pixel_in0 = gray ? gray_in0 : rgb_in0;
    assign pixel_in1 = gray ? gray_in1 : rgb_in1;
    assign pixel_in2 = gray ? gray_in2 : rgb_in2;

    // pipeline conv_array and basic_ALU
    logic [35:0] pixel_in0_reg, pixel_in1_reg, pixel_in2_reg;
    logic [2:0] func_reg;
    logic we;

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            pixel_in0_reg <= 0;
            pixel_in1_reg <= 0;
            pixel_in2_reg <= 0;
            func_reg <= 0;
            we_reg <= 0;
            start_reg <= 0;
            done_reg <= 0;
        end
        else begin
            pixel_in0_reg <= pixel_in0;
            pixel_in1_reg <= pixel_in1;
            pixel_in2_reg <= pixel_in2;
            func_reg <= func;
            we_reg <= we;
            start_reg <= start;
            done_reg <= done;
        end
    end


    basic_ALU basic_ALU0(
        .pixel_in(pixel_in1_reg[23:12]),
        .func(func_reg[1:0]),
        .pixel_out(basic_ALU_out)
    );

    conv_array conv_array0(
        .pixel_in0(pixel_in0_reg),
        .pixel_in1(pixel_in1_reg),
        .pixel_in2(pixel_in2_reg),
        .func(func_reg[1:0]),
        .data_out(conv_out)
    );

    assign data_out = func_reg[2] ? conv_out : basic_ALU_out;

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            we <= 0;
        end
        else if (cnt_start) begin
            we <= 1;
        end
        else if (done) begin
            we <= 0;
        end
    end

endmodule