module calc_meta(
    input logic clk,
    input logic rst_n,
    input logic [11:0] pixel_in,
    input logic [2:0] func,
    output logic [11:0] min,
    output logic [11:0] max
);
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            min <= '1;
        end
        // TODO: think about when to update min and max
        else if (&func) begin
            if (pixel_in[3:0] < min[3:0])
                min[3:0] <= pixel_in[3:0];
            if (pixel_in[7:4] < min[7:4])
                min[7:4] <= pixel_in[7:4];
            if (pixel_in[11:8] < min[11:8])
                min[11:8] <= pixel_in[11:8];
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            max <= '0;
        end
        else if (&func) begin
            if (pixel_in[3:0] > max[3:0])
                max[3:0] <= pixel_in[3:0];
            if (pixel_in[7:4] > max[7:4])
                max[7:4] <= pixel_in[7:4];
            if (pixel_in[11:8] > max[11:8])
                max[11:8] <= pixel_in[11:8];
        end
    end

endmodule