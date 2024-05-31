/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 2

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
`default_nettype none
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, func3, SET);

    parameter OPERAND_WIDTH = 32;    
    parameter NUM_OPERATIONS = 3;
    
    input wire SET;
    input wire  [2:0] func3;
    input wire  [OPERAND_WIDTH -1:0] InA ; // Input wire operand A
    input wire  [OPERAND_WIDTH -1:0] InB ; // Input wire operand B
    input wire                       Cin ; // Carry in
    input wire  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input wire                       invA; // Signal to invert A
    input wire                       invB; // Signal to invert B
    input wire                       sign; // Signal for signed operation
    output wire [OPERAND_WIDTH -1:0] Out ; // Result of comput wireation
    // output wire                      Ofl ; // Signal if overflow occured
    // output wire                      Zero; // Signal if Out is 0
    // output wire                      take_branch; // Signal if branch should be taken

    /* YOUR CODE HERE */
    wire [OPERAND_WIDTH - 1 : 0] A, B, shifter_out, AL_out;
    wire cOut, Zero;

    assign A = invA ? ~InA : InA;
    assign B = invB ? ~InB : InB;

    al      al_0      (.InA(A), .InB(B), .Cin(Cin), .Oper(Oper[1 : 0]), .sign(sign), .Out(AL_out), .Ofl(), .Zero(Zero), .cOut1(cOut));
    shifter shifter_0 (.InBS(A), .ShAmt(B[4 : 0]), .ShiftOper(Oper[1 : 0]), .OutBS(shifter_out));
    

    // branch flags

    wire gt, lt, eq;
    assign eq = Zero;
    assign gt = ~eq & (sign ? ((InA[31] == InB[31]) ? ~AL_out[31] : ~InA[31]) : cOut);
    assign lt = ~eq & ~gt;

    // assign take_branch =    func3 == 3'b000 ? eq : 
    //                         func3 == 3'b001 ? ~eq : 
    //                         func3 == 3'b100 ? lt : 
    //                         func3 == 3'b101 ? gt | eq : 
    //                         func3 == 3'b110 ? lt : gt | eq;


    assign Out = SET ? lt : Oper[2] ? AL_out : shifter_out;

    
endmodule
`default_nettype wire
