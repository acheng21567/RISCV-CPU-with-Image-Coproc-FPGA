/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 32-bit register.
*/
`default_nettype none
module reg32 (
            // Output
            q,
            // Inputs
            d, clk, rst, writeEn
            );

    parameter WIDTH = 32;

    output wire [WIDTH-1:0]  q;
    input wire  [WIDTH-1:0]  d;
    input wire               clk;
    input wire               rst;
    input wire               writeEn;

    wire [WIDTH-1:0] dataWrite;

    assign dataWrite = writeEn ? d : q;

    dff dffs [WIDTH-1:0] (.q(q), .d(dataWrite), .clk(clk), .rst(rst));

endmodule
`default_nettype wire
