module conv_unit(
    input logic [3:0] color_in00,
    input logic [3:0] color_in01,
    input logic [3:0] color_in02,
    input logic [3:0] color_in10,
    input logic [3:0] color_in11,
    input logic [3:0] color_in12,
    input logic [3:0] color_in20,
    input logic [3:0] color_in21,
    input logic [3:0] color_in22,
    input logic [1:0] func,
    output logic [3:0] data_out
);
    logic signed [11:0] temp;
    logic [7:0] color_00, color_01, color_02, color_10, color_11, color_12, color_20, color_21, color_22;

    assign color_00 = {4'b0, color_in00};
    assign color_01 = {4'b0, color_in01};
    assign color_02 = {4'b0, color_in02};
    assign color_10 = {4'b0, color_in10};
    assign color_11 = {4'b0, color_in11};
    assign color_12 = {4'b0, color_in12};
    assign color_20 = {4'b0, color_in20};
    assign color_21 = {4'b0, color_in21};
    assign color_22 = {4'b0, color_in22};
    
    always_comb begin
        case (func)
            // -1 -1 -1 -1 8 -1 -1 -1 -1
            2'b00: begin
                // temp = - color_00 - color_01 - color_02 - color_10 + ((color_11 << 3) + color_11) - color_12 - color_20 - color_21 - color_22;
                temp = - (color_00 + color_01 + color_02 + color_10 + color_12 + color_20 + color_21 + color_22) + (color_11 << 3);
            end
            // 1 2 1 2 4 2 1 2 1 / 16
            2'b01: begin
                temp = (color_00 + (color_01 << 1) + color_02 + (color_10 << 1) + (color_11 << 2) + (color_12 << 1) + color_20 + (color_21 << 1) + color_22) >> 4;
            end
            // 0 -1 0 -1 5 -1 0 -1 0
            2'b10: begin
                // temp = - color_01 - color_10 + ((color_11 << 2) + color_11) - color_12 - color_21;
                temp = - (color_01 + color_10 + color_12 + color_21) + ((color_11 << 2) + color_11);
            end
            // nop
            default: begin
                temp = color_11;
            end
        endcase
    end
    
    // assign data_out = temp[3:0];
    assign data_out = (temp > 15) ? 15 : ((temp < 0) ? 0 : temp[3:0]);

endmodule