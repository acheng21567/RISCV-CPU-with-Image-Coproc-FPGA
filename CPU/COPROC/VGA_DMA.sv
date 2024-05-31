module VGA_DMA(
    input logic clk,
    input logic rst_n,
    input logic we_in,
    input logic start,
    input logic img_idx,
    output logic [16:0] waddr,
    output logic we_out
);
    logic [16:0] col_cnt;

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            col_cnt <= '0;
        end 
        else if (start) begin
            col_cnt <= '0;
        end
        else if (we_in & ~col_cnt[16]) begin
            col_cnt <= col_cnt + 1;
        end 
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            waddr <= '0;
        end 
        else if (start) begin
            waddr <= img_idx ? 9'd256 : '0;
        end
        // else if (we_in & (|col_cnt[16:8] & (~|col_cnt[7:0]))) begin
        else if (we_in & (&col_cnt[7:0])) begin
            waddr <= waddr + 9'd257;
        end
        else if (we_in) begin
            waddr <= waddr + 1;
        end
    end

    assign we_out = col_cnt[16] ? 0 : we_in;

endmodule