module data_accum(
    input logic clk,
    input logic rst_n,
    input logic we_in,
    input logic [11:0] wdata_in,
    output logic [3071:0] wdata_out
);
    // R: [11:8], G: [7:4], B: [3:0] 
    // pixel 0 is at the LSB
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            wdata_out <= '0;
        end
        else if (we_in) begin
            wdata_out <= {wdata_in, wdata_out[3071:12]};
        end
    end

endmodule