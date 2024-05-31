
`default_nettype none
module control (
    input wire [31:0] instr,
    output wire LUI, JALR, AUIPC, SET, I, S, R, B, U, J, reg_write, mem_en, mem_rd_wr, mem_to_reg,
    output wire [2:0] ALUOp,
    output wire Cin, invA, invB, sign
);

    assign LUI = instr[6:0] == 7'b0110111;
    assign JALR = instr[6:0] == 7'b1100111;
    assign AUIPC = instr[6:0] == 7'b0010111;
    assign I = (instr[6:0] == 7'b0000011) | (instr[6:0] == 7'b0010011);
    assign S = instr[6:0] == 7'b0100011;
    assign R = (instr[6:0] == 7'b0110011);
    assign B = instr[6:0] == 7'b1100011;
    assign U = LUI | AUIPC;
    assign J = (instr[6:0] == 7'b1101111) | JALR;
    assign SET = instr[4] & ~AUIPC & (instr[14:13] == 2'b01);

    assign reg_write = R | I | U | J;
    assign mem_rd_wr = S;
    assign mem_to_reg = instr[6:0] == 7'b0000011;
    assign mem_en = mem_rd_wr | mem_to_reg;

    assign ALUOp =   (B | U | J | S) ? 3'b100 : 
        (instr[14:12] == 3'b111) ? 3'b101 :
        (instr[14:12] == 3'b110) ? 3'b110 :
        (instr[14:12] == 3'b100) ? 3'b111 :
        (instr[14:12] == 3'b001) ? 3'b000 :
        (instr[14:12] == 3'b101) ? (instr[31] ? 3'b011 : 3'b001) : 3'b100;
    
    assign sign = SET ? (~instr[12]) : B ? (~instr[13]) : ((R | I) ? (instr[14:12] == 3'b011) : 1'b0);
    assign {Cin, invA, invB} =  (S | U | J) ? 3'b000 : 
                                (B)         ? 3'b101 :
                                (SET) ? 3'b101       : 
                                (instr[30] & R & (~|instr[14:12])) ? 3'b101 : // SUB
                                                                     3'b000;

endmodule
`default_nettype wire