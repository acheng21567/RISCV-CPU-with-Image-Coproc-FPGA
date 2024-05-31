/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
`default_nettype none
module shifter (InBS, ShAmt, ShiftOper, OutBS);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 32;
    parameter SHAMT_WIDTH   =  5;
    parameter NUM_OPERATIONS = 2;

    input wire [OPERAND_WIDTH -1:0] InBS;  // Input operand
    input wire [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input wire [NUM_OPERATIONS-1:0] ShiftOper;  // Operation type
    output wire [OPERAND_WIDTH -1:0] OutBS;  // Result of shift/rotate

   /* YOUR CODE HERE */
    wire [OPERAND_WIDTH - 1 : 0] imSF_0, imSF_1, imSF_2, imSF_3;

    // use assign to perform shift operations
    // ShiftOper == 00 -> shift left logical
    // ShiftOper == 01 -> shift right logical
    // ShiftOper == 11 -> shift right arithmetic
    // ShiftOper == 10 -> UNUSED

    assign imSF_0 = ShiftOper[0] ? 
                    (ShAmt[0] ? {ShiftOper[1] ? {1{InBS[OPERAND_WIDTH - 1]}} : 1'b0, InBS[OPERAND_WIDTH - 1 : 1]} : InBS) : 
                    (ShAmt[0] ? {InBS[OPERAND_WIDTH - 2 : 0], ShiftOper[1] ? InBS[OPERAND_WIDTH - 1 : OPERAND_WIDTH - 1] : 1'b0} : InBS) ;

    assign imSF_1 = ShiftOper[0] ? 
                    (ShAmt[1] ? {ShiftOper[1] ? {2{imSF_0[OPERAND_WIDTH - 1]}} : 2'b0, imSF_0[OPERAND_WIDTH - 1 : 2]} : imSF_0) : 
                    (ShAmt[1] ? {imSF_0[OPERAND_WIDTH - 3 : 0], ShiftOper[1] ? imSF_0[OPERAND_WIDTH - 1 : OPERAND_WIDTH - 2] : 2'b0} : imSF_0) ;

    assign imSF_2 = ShiftOper[0] ? 
                    (ShAmt[2] ? {ShiftOper[1] ? {4{imSF_1[OPERAND_WIDTH - 1]}} : 4'b0, imSF_1[OPERAND_WIDTH - 1 : 4]} : imSF_1) : 
                    (ShAmt[2] ? {imSF_1[OPERAND_WIDTH - 5 : 0], ShiftOper[1] ? imSF_1[OPERAND_WIDTH - 1 : OPERAND_WIDTH - 4] : 4'b0} : imSF_1) ;

    assign imSF_3 = ShiftOper[0] ? 
                    (ShAmt[3] ? {ShiftOper[1] ? {8{imSF_2[OPERAND_WIDTH - 1]}} : 8'b0, imSF_2[OPERAND_WIDTH - 1 : 8]} : imSF_2) : 
                    (ShAmt[3] ? {imSF_2[OPERAND_WIDTH - 9 : 0], ShiftOper[1] ? imSF_2[OPERAND_WIDTH - 1 : OPERAND_WIDTH - 8] : 8'b0} : imSF_2) ;

    assign OutBS  = ShiftOper[0] ? 
                    (ShAmt[4] ? {ShiftOper[1] ? {16{imSF_3[OPERAND_WIDTH - 1]}} : 16'b0, imSF_3[OPERAND_WIDTH - 1 : 16]} : imSF_3) : 
                    (ShAmt[4] ? {imSF_3[OPERAND_WIDTH - 17 : 0], ShiftOper[1] ? imSF_3[OPERAND_WIDTH - 1 : OPERAND_WIDTH - 16] : 16'b0} : imSF_3) ;
    
   
endmodule
`default_nettype wire
