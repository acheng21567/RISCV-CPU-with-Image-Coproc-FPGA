/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
`default_nettype none
module fullAdder1b(s, cOut, inA, inB, cIn);
    output wire s;
    output wire cOut;
    input  wire inA, inB;
    input  wire cIn;

    // YOUR CODE HERE
	wire xor_0_out, and_0_out, and_1_out;
	xor2 xor_0(.out(xor_0_out), .in1(inA), .in2(inB));
	xor2 xor_1(.out(s), .in1(xor_0_out), .in2(cIn));
	and2 and_0(.out(and_0_out), .in1(inA), .in2(inB));
	and2 and_1(.out(and_1_out), .in1(xor_0_out), .in2(cIn));
	or2 or_0(.out(cOut), .in1(and_0_out), .in2(and_1_out));
	

endmodule
`default_nettype wire
