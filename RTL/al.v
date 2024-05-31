/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 2

    A block for Arithmetic Logic Unit (ALU) module.  It is designed to perform
    addition, subtraction, and bitwise operations on two 16-bit numbers.
*/
`default_nettype none
module al (InA, InB, Cin, Oper, sign, Out, Zero, Ofl, cOut1);

    parameter OPERAND_WIDTH = 32;    
    parameter NUM_OPERATIONS = 2;
       
    input wire  [OPERAND_WIDTH -1:0] InA ; // Input wire operand A
    input wire  [OPERAND_WIDTH -1:0] InB ; // Input wire operand B
    input wire                       Cin ; // Carry in
    input wire  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input wire                       sign; // Signal for signed operation
    output wire [OPERAND_WIDTH -1:0] Out ; // Result of comput wireation
    output wire                      Ofl ; // Signal if overflow occured
    output wire                      Zero; // Signal if Out is 0
    output wire                      cOut1; // Carry out

    wire [OPERAND_WIDTH - 1 : 0] CLA_out, AND_out, OR_out, XOR_out;
    wire CLA_Ofl, cOut0, Ofl0;

    cla16b CLA16_0 [1:0] (.sum(CLA_out), .cOut({cOut1, cOut0}), .inA(InA), .inB(InB), .cIn({cOut0, Cin}), .sign(sign), .Ofl({Ofl, Ofl0}));
    
    assign AND_out = InA & InB;
    assign OR_out = InA | InB;
    assign XOR_out = InA ^ InB;
    
    assign Out = Oper[1] ? (Oper[0] ? XOR_out : OR_out) : (Oper[0] ? AND_out : CLA_out);
    assign Zero = ~|Out;


endmodule
`default_nettype wire