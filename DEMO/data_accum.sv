// /////////////////////////////////////////////////////////////////////////////
// Program: data_accum.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Data accumulation module that accumulates 256 pixels to form a row of image data
// 
//  - Inputs:
//     clk: 	Global clock signal for 25MHz
//     rst_n: 	Global active low reset
//     we_in: 	Write enable for writing and shifting 12-bit wdata_in into the shift register 
//     wdata_in [11:0]: 	12-bit input write data to be written into the shift register
// 
//  - Outputs:
//     wdata_out [3071:0]: 	3072-bit output write data to be written into the image buffer
// /////////////////////////////////////////////////////////////////////////////

module data_accum(
    input logic clk,
    input logic rst_n,
    input logic we_in,
    input logic [11:0] wdata_in,
    output logic [3071:0] wdata_out
);

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // R: [11:8], G: [7:4], B: [3:0] 
    // pixel 0 is at the LSB
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            wdata_out <= '0;
        end
        // shift in the new data to accumulate a row of 256 pixels
        else if (we_in) begin
            wdata_out <= {wdata_in, wdata_out[3071:12]};
        end
    end

endmodule