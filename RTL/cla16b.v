/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
`default_nettype none
module cla16b(sum, cOut, inA, inB, cIn, sign, Ofl);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output wire [N-1:0] sum;
    output wire         cOut;
	output wire         Ofl;
    input wire [N-1: 0] inA, inB;
    input wire          cIn;
	input wire          sign;

    // YOUR CODE HERE
	wire [N-1:0] p, g;
	wire [3:0] P, G, C;
	assign C[0] = cIn;
	
	cla4b cla_0 [3:0] (.sum(sum), .inA(inA), .inB(inB), .cOut(), .cIn(C), .p(p), .g(g));
	
	// P bits for 4 CLA_4b
	and4 P_and [3:0] (.out(P),	.in1({p[15], p[11], p[7], p[3]}),
							    .in2({p[14], p[10], p[6], p[2]}),
							    .in3({p[13], p[9],  p[5], p[1]}),
							    .in4({p[12], p[8],  p[4], p[0]}));
	
	// G bits for 4 CLA_4b
	wire [3:0] G_2, G_3, G_4;
	
	and2 G_2_and [3:0] (.out(G_2), 	.in1({p[15], p[11], p[7], p[3]}),
									.in2({g[14], g[10], g[6], g[2]}));
										   
	and3 G_3_and [3:0] (.out(G_3), 	.in1({p[15], p[11], p[7], p[3]}),
									.in2({p[14], p[10], p[6], p[2]}),
									.in3({g[13], g[9] , g[5], g[1]}));

	and4 G_4_and [3:0] (.out(G_4), 	.in1({p[15], p[11], p[7], p[3]}),
									.in2({p[14], p[10], p[6], p[2]}),
									.in3({p[13], p[9],  p[5], p[1]}),
									.in4({g[12], g[8],  g[4], g[0]}));
										   
	or4 g4_or [3:0] (.out(G), 		.in1({g[15], g[11], g[7], g[3]}),
									.in2(G_2),
									.in3(G_3),
									.in4(G_4));
	
	wire C1_0, C2_0, C2_1, C3_0, C3_1, C3_2, C4_0, C4_1, C4_2, C4_3;
	
	// Get CIn for CLA0
	and2 C1_and_0(.out(C1_0), .in1(P[0]), .in2(C[0]));
	or2 C1_or_0(.out(C[1]), .in1(G[0]), .in2(C1_0));
	
	// Get CIn for CLA1
	and2 C2_and_0(.out(C2_0), .in1(P[1]), .in2(G[0]));
	and3 C2_and_1(.out(C2_1), .in1(P[1]), .in2(P[0]), .in3(C[0]));
	or3 C2_or_0(.out(C[2]), .in1(G[1]), .in2(C2_0), .in3(C2_1));
	
	// Get CIn for CLA2
	and2 C3_and_0(.out(C3_0), .in1(P[2]), .in2(G[1]));
	and3 C3_and_1(.out(C3_1), .in1(P[2]), .in2(P[1]), .in3(G[0]));
	and4 C3_and_2(.out(C3_2), .in1(P[2]), .in2(P[1]), .in3(P[0]), .in4(C[0]));
	or4 C3_or_0(.out(C[3]), .in1(G[2]), .in2(C3_0), .in3(C3_1), .in4(C3_2));
	
	// Get CIn for CLA3
	and2 C4_and_0(.out(C4_0), .in1(P[3]), .in2(G[2]));
	and3 C4_and_1(.out(C4_1), .in1(P[3]), .in2(P[2]), .in3(G[1]));
	and4 C4_and_2(.out(C4_2), .in1(P[3]), .in2(P[2]), .in3(P[1]), .in4(G[0]));
	and5 C4_and_3(.out(C4_3), .in1(P[3]), .in2(P[2]), .in3(P[1]), .in4(P[0]), .in5(C[0]));
	or5 C4_or_0(.out(cOut), .in1(G[3]), .in2(C4_0), .in3(C4_1), .in4(C4_2), .in5(C4_3));

	// Get Ofl
	wire Ofl_signed, same_sign_ofl;

	assign same_sign_ofl = (~sum[15] & inA[15] & inB[15]) | ~(~sum[15] | inA[15] | inB[15]);
	assign Ofl_signed = (inA[15] ^ inB[15]) ? 1'b0 : same_sign_ofl;

	assign Ofl = sign ? Ofl_signed : cOut;

endmodule
`default_nettype wire
