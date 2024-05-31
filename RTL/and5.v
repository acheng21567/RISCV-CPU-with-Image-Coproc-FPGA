/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    5 input AND
*/
`default_nettype none
module and5 (out,in1,in2,in3,in4,in5);
    output wire out;
    input wire in1,in2,in3,in4,in5;
	
	wire and_imm;
	and3 and_3_0(.in1(in1), .in2(in2), .in3(in3), .out(and_imm));
	and3 and_3_1(.out(out), .in1(and_imm), .in2(in4), .in3(in5));
	
endmodule
`default_nettype wire
