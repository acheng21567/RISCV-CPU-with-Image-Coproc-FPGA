`default_nettype none
module alu_control (
    input wire [31:0] instr,
    output wire [2:0] ALUOp,
    output wire Cin, invA, invB, sign
);
    // assign ALUOp =   (B | U | J | S) ? 3'b100 : 
    //         (instr[14:12] == 3'b111) ? 3'b101 :
    //         (instr[14:12] == 3'b110) ? 3'b110 :
    //         (instr[14:12] == 3'b100) ? 3'b111 :
    //         (instr[14:12] == 3'b001) ? 3'b000 :
    //         (instr[14:12] == 3'b101) ? (instr[31] ? 3'b011 : 3'b001) : 3'b100;
    
    // assign sign = B ? (~instr[13]) : ((R | I) ? (instr[14:12] == 3'b011) : 1'b0);
    // assign {Cin, invA, invB} =  (S | U | J) ? 3'b000 : 
    //                             (B)         ? 3'b101 :
    //                             (instr[14:13] == 2'b01 & instr[5]) ? 3'b101 : (instr[31] & R) ? 3'b101 : 3'b000;

endmodule
`default_nettype wire