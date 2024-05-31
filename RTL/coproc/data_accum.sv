module data_accum(
    input logic clk,
    input logic rst_n,
    input logic we_in,
    input logic start,
    input logic [7:0] col_cnt,
    input logic [11:0] wdata_in,
    output logic [3071:0] wdata_out
);
    logic [3071:0] shift_reg0, shift_reg1;
    logic reg_sel;

    // enable bank write. Only start write after the shift register is full for the second time
    // logic bank_write;

    // R: [11:8], G: [7:4], B: [3:0] 
    // pixel 0 is at the LSB
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            shift_reg0 <= '0;
        end
        else if (we_in & ~reg_sel) begin
            shift_reg0 <= {wdata_in, shift_reg0[3071:12]};
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            shift_reg1 <= '0;
        end
        else if (we_in & reg_sel) begin
            shift_reg1 <= {wdata_in, shift_reg1[3071:12]};
        end
    end

    // alternate the output between shift_reg0 and shift_reg1
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            reg_sel <= 1;
        end
        else if (~(|col_cnt)) begin
            reg_sel <= ~reg_sel;
        end
    end

    // TODO: to be tested
    assign wdata_out = ~reg_sel ? shift_reg1 : shift_reg0;

endmodule