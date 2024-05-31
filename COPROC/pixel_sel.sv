module pixel_sel(
    input logic [3071:0] rdata0_in,
    input logic [3071:0] rdata1_in,
    input logic [3071:0] rdata2_in,
    input logic [7:0] col_cnt,
    input logic [2:0] reg_sel,
    output logic [35:0] rdata0_out,
    output logic [35:0] rdata1_out,
    output logic [35:0] rdata2_out
);
    logic [11:0] pixel00, pixel01, pixel02, pixel10, pixel11, pixel12, pixel20, pixel21, pixel22;

    logic [3095:0] tmp0, tmp1, tmp2;
    assign tmp0 = {12'b0, rdata0_in, 12'b0};
    assign tmp1 = {12'b0, rdata1_in, 12'b0};
    assign tmp2 = {12'b0, rdata2_in, 12'b0};


    always_comb begin
        pixel00 = (col_cnt > 0)   ? tmp0[(col_cnt-1)*12 +: 12] : 12'b0;
        pixel10 = (col_cnt > 0)   ? tmp1[(col_cnt-1)*12 +: 12] : 12'b0;
        pixel20 = (col_cnt > 0)   ? tmp2[(col_cnt-1)*12 +: 12] : 12'b0;

        pixel01 = tmp0[col_cnt*12 +: 12];
        pixel11 = tmp1[col_cnt*12 +: 12];
        pixel21 = tmp2[col_cnt*12 +: 12];

        pixel02 = (col_cnt < 255) ? tmp0[(col_cnt+1)*12 +: 12] : 12'b0;
        pixel12 = (col_cnt < 255) ? tmp1[(col_cnt+1)*12 +: 12] : 12'b0;
        pixel22 = (col_cnt < 255) ? tmp2[(col_cnt+1)*12 +: 12] : 12'b0;
    end

    // reorganize the pixel order based on row_sel_onehot
    always_comb begin
        case (reg_sel)
            3'b100: begin
                rdata0_out = {pixel00, pixel01, pixel02};
                rdata1_out = {pixel10, pixel11, pixel12};
                rdata2_out = {pixel20, pixel21, pixel22};
            end
            3'b001: begin
                rdata0_out = {pixel10, pixel11, pixel12};
                rdata1_out = {pixel20, pixel21, pixel22};
                rdata2_out = {pixel00, pixel01, pixel02};
            end
            3'b010: begin
                rdata0_out = {pixel20, pixel21, pixel22};
                rdata1_out = {pixel00, pixel01, pixel02};
                rdata2_out = {pixel10, pixel11, pixel12};
            end
            default: begin
                rdata0_out = '0;
                rdata1_out = '0;
                rdata2_out = '0;
            end
        endcase
    end


endmodule