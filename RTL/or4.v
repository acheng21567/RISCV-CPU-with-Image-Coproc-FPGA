/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    4 input OR
*/
`default_nettype none
module or4 (out,in1,in2,in3,in4);
    output wire out;
    input wire in1,in2,in3,in4;
	
	wire or_imm;
	or3 or_3(.in1(in1), .in2(in2), .in3(in3), .out(or_imm));
	or2 or_2(.out(out), .in1(or_imm), .in2(in4));
	
endmodule
`default_nettype wire
