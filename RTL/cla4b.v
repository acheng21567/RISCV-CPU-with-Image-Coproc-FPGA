/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
`default_nettype none
module cla4b(sum, cOut, p, g, inA, inB, cIn);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output wire [N-1:0] sum;
    output wire         cOut;
	output wire	[N-1:0] p, g;
    input wire [N-1: 0] inA, inB;
    input wire          cIn;

    // YOUR CODE HERE
	// wire [N-1:0] p, g;
	wire [N-1:0] c;
	assign c[0] = cIn;
	
	wire c1_0, c2_0, c2_1, c3_0, c3_1, c3_2, c4_0, c4_1, c4_2, c4_3;
	
	// get small p and g bits from input
	xor2 p_xor [N-1:0] (.out(p), .in1(inA), .in2(inB));
	and2 g_and [N-1:0] (.out(g), .in1(inA), .in2(inB));
	
	// get cIn for FA0
	and2 c1_and_0(.out(c1_0), .in1(p[0]), .in2(c[0]));
	or2 c1_or_0(.out(c[1]), .in1(g[0]), .in2(c1_0));
	
	// get cIn for FA1
	and2 c2_and_0(.out(c2_0), .in1(p[1]), .in2(g[0]));
	and3 c2_and_1(.out(c2_1), .in1(p[1]), .in2(p[0]), .in3(c[0]));
	or3 c2_or_0(.out(c[2]), .in1(g[1]), .in2(c2_0), .in3(c2_1));
	
	// get cIn for FA2
	and2 c3_and_0(.out(c3_0), .in1(p[2]), .in2(g[1]));
	and3 c3_and_1(.out(c3_1), .in1(p[2]), .in2(p[1]), .in3(g[0]));
	and4 c3_and_2(.out(c3_2), .in1(p[2]), .in2(p[1]), .in3(p[0]), .in4(c[0]));
	or4 c3_or_0(.out(c[3]), .in1(g[2]), .in2(c3_0), .in3(c3_1), .in4(c3_2));
	
	// get cIn for FA3
	and2 c4_and_0(.out(c4_0), .in1(p[3]), .in2(g[2]));
	and3 c4_and_1(.out(c4_1), .in1(p[3]), .in2(p[2]), .in3(g[1]));
	and4 c4_and_2(.out(c4_2), .in1(p[3]), .in2(p[2]), .in3(p[1]), .in4(g[0]));
	and5 c4_and_3(.out(c4_3), .in1(p[3]), .in2(p[2]), .in3(p[1]), .in4(p[0]), .in5(c[0]));
	or5 c4_or_0(.out(cOut), .in1(g[3]), .in2(c4_0), .in3(c4_1), .in4(c4_2), .in5(c4_3));
	
	// cout is no longer used
	fullAdder1b fa_0 [N-1:0] (.s(sum), .cOut(), .inA(inA), .inB(inB), .cIn(c));

endmodule
`default_nettype wire
