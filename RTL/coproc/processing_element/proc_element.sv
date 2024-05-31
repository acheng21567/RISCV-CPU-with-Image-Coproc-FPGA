module proc_element(
    input logic clk,
    input logic rst_n,
    input logic [35:0] rgb_in0,
    input logic [35:0] rgb_in1,
    input logic [35:0] rgb_in2,
    input logic [2:0] func,
    input logic gray,
    input logic start,
    // input logic rdy_in,
    output logic rdy,
    output logic we,
    output logic [11:0] data_out,
    output logic done
);
    logic [35:0] gray_in0, gray_in1, gray_in2;
    logic [35:0] pixel_in0, pixel_in1, pixel_in2;
    logic [11:0] basic_ALU_out, conv_out;
    logic [11:0] min, max;
    logic [15:0] counter;
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

    basic_ALU basic_ALU0(
        .pixel_in(pixel_in1[23:12]),
        .func(func[1:0]),
        .min(min),
        .max(max),
        .pixel_out(basic_ALU_out)
    );

    conv_array conv_array0(
        .pixel_in0(pixel_in0),
        .pixel_in1(pixel_in1),
        .pixel_in2(pixel_in2),
        .func(func[1:0]),
        .data_out(conv_out)
    );

    assign data_out = func[2] ? conv_out : basic_ALU_out;

    calc_meta calc_meta0(
        .clk(clk),
        .rst_n(rst_n),
        .pixel_in(rgb_in1[23:12]),
        .func(func),
        .min(min),
        .max(max)
    );

    // counter logic
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            counter <= '0;
        end
        else if (start) begin
            counter <= '0;
        end
        else if (~&counter) begin
            counter <= counter + 1;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            we <= 0;
        end
        else if (start) begin
            we <= 1;
        end
        else if (rdy) begin
            we <= 0;
        end
        prev_rdy <= rdy;
    end

    assign rdy = &counter;
    assign done = rdy & ~prev_rdy;

endmodule