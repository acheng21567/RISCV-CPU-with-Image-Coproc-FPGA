/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    4 input AND
*/
`default_nettype none
module and4 (out,in1,in2,in3,in4);
    output wire out;
    input wire in1,in2,in3,in4;
	
	wire and_imm;
	and3 and_3(.in1(in1), .in2(in2), .in3(in3), .out(and_imm));
	and2 and_2(.out(out), .in1(and_imm), .in2(in4));
	
endmodule
`default_nettype wire
