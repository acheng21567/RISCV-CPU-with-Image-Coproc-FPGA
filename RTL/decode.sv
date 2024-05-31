`default_nettype none
module decode (
    input wire clk,
    input wire rst,
    input wire [31:0] instr_IF_ID_original,
    input wire [31:0] rf_data1_out,
    input wire [31:0] rf_data2_out,
    input wire [31:0] pc_IF_ID,
    input wire B_J_EX,
    input wire lw_stall,
    
    input wire [31:0] alu_result_EX_forward, alu_result_MEM_forward,
    input wire reg_write_EX_forward, reg_write_MEM_forward,
    input wire [4:0] rd_EX_forward, rd_MEM_forward,

    output wire [4:0] rs1_ID_EX,
    output wire [4:0] rs2_ID_EX,
    output wire [4:0] rd_ID_EX,
    output wire [31:0] data1_ID_EX,
    output wire [31:0] data2_ID_EX,
    output wire [31:0] imm_out_ID_EX,
    output wire LUI_ID_EX, J_ID_EX, B_ID_EX, JALR_ID_EX, SET_ID_EX, R_ID_EX, AUIPC_ID_EX,
    output wire Cin_ID_EX, invA_ID_EX, invB_ID_EX, sign_ID_EX,
    output wire [2:0] ALUOp_ID_EX,
    output wire reg_write_ID_EX, mem_en_ID_EX, mem_rd_wr_ID_EX, mem_to_reg_ID_EX,
    output wire [31:0] pc_ID_EX, instr_ID_EX,
    output wire [4:0] rs1, rs2,
    output wire [31:0] rf_data1_ID_EX, rf_data2_ID_EX,
    output wire [31:0] B_J_pc_ID_EX,
    output wire B_J_ID_EX,
    output wire stall_ID_EX,
    output wire S_ID_EX,
    output wire cond_for_lw_stall,
    output wire br_stall
);

    wire [31:0] imm_IorJALR, imm_S, imm_B, imm_U, imm_J;
    wire AUIPC, I, S, R, U;
    wire [2:0] ALUOp;
    wire reg_write, mem_en, mem_rd_wr, mem_to_reg;
    // wire [4:0] rs1, rs2, rd;
    wire [4:0] rd;
    wire [31:0] data1, data2, imm_out;
    wire LUI, JALR, J, B, SET;
    wire Cin, invA, invB, sign;
    wire [31:0] instr_IF_ID;
    wire stall;

    assign stall = lw_stall;

    assign instr_IF_ID = B_J_EX ? 32'h0 : instr_IF_ID_original;

    assign rs1 = instr_IF_ID[19:15];
    assign rs2 = instr_IF_ID[24:20];
    assign rd = instr_IF_ID[11:7];

    assign imm_IorJALR = { {20{instr_IF_ID[31]}}, instr_IF_ID[31:20] };
    assign imm_S = { {20{instr_IF_ID[31]}}, instr_IF_ID[31:25], instr_IF_ID[11:7] };
    assign imm_B = { {11{instr_IF_ID[31]}}, instr_IF_ID[31], instr_IF_ID[7], instr_IF_ID[30:25], instr_IF_ID[11:8], 1'b0 };
    assign imm_U = { instr_IF_ID[31:12], 12'b0 };
    assign imm_J = { {11{instr_IF_ID[31]}}, instr_IF_ID[31], instr_IF_ID[19:12], instr_IF_ID[20], instr_IF_ID[30:21], 1'b0 };

    assign data1 = (AUIPC | J) ? pc_IF_ID : rf_data1_out;
    assign data2 = J ? 4 : ((R | B) ? rf_data2_out : imm_out);

    assign imm_out = (I | JALR) ? imm_IorJALR : S ? imm_S : B ? imm_B : U ? imm_U : imm_J;

    wire [31:0] comp_out, pc_sum, pc_addr_src, pc_offset, B_J_pc;
    wire gt, lt, eq, comp_cout1, comp_cout0, pc_cout1, pc_cout0, take_branch, off_src;
    wire [2:0] func3;
    wire [31:0] branch_comp_in1, branch_comp_in2;
    wire forward_M_D, forward_X_D;

    cla16b iCLA0 [1:0] (.sum(comp_out), .cOut({comp_cout1, comp_cout0}), .inA(branch_comp_in1), .inB(~branch_comp_in2), .cIn({comp_cout0, Cin}), .sign(sign), .Ofl());



    assign eq = ~|comp_out;
    assign gt = ~eq & (sign ? ((branch_comp_in1[31] == branch_comp_in2[31]) ? ~comp_out[31] : ~branch_comp_in1[31]) : comp_cout1);
    assign lt = ~eq & ~gt;

    assign func3 = instr_IF_ID[14:12];
    assign take_branch =    func3 == 3'b000 ? eq : 
                            func3 == 3'b001 ? ~eq : 
                            func3 == 3'b100 ? lt : 
                            func3 == 3'b101 ? gt | eq : 
                            func3 == 3'b110 ? lt : gt | eq;

    cla16b iCLA1 [1:0] (.sum(pc_sum), .cOut({pc_cout1, pc_cout0}), .inA(pc_addr_src), .inB(pc_offset), .cIn({pc_cout0, 1'b0}), .sign(1'b0), .Ofl());

    assign off_src = J | (take_branch & B);
    assign pc_offset = off_src ? imm_out : 32'h00000004;
    assign pc_addr_src = JALR ? branch_comp_in1 : pc_IF_ID;

    assign B_J_pc = JALR ? {pc_sum[31:2], 2'b00} : pc_sum;

    assign cond_for_lw_stall = R | B | S | JALR;

    assign br_stall = ((rs1 == rd_ID_EX) | (rs2 == rd_ID_EX) | (rs1 == rd_EX_forward) | (rs2 == rd_EX_forward)) & (B);
    // assign br_stall = 1'b0;

    assign forward_M_D = (rd_MEM_forward != 0) & reg_write_MEM_forward;
    assign forward_X_D = (rd_EX_forward != 0) & reg_write_EX_forward;
    assign branch_comp_in1 = (forward_X_D & (rs1 == rd_EX_forward) & (B | JALR)) ? alu_result_EX_forward : (forward_M_D & (rs1 == rd_MEM_forward) & (B | JALR)) ? alu_result_MEM_forward : rf_data1_out;
    assign branch_comp_in2 = (forward_X_D & (rs2 == rd_EX_forward) & (B)) ? alu_result_EX_forward : (forward_M_D & (rs2 == rd_MEM_forward) & (B)) ? alu_result_MEM_forward : rf_data2_out;



    control iCONTROL (
        .instr(instr_IF_ID),
        .LUI(LUI),
        .JALR(JALR),
        .AUIPC(AUIPC),
        .I(I),
        .S(S),
        .R(R),
        .B(B),
        .U(U),
        .J(J),
        .SET(SET),
        .reg_write(reg_write),
        .mem_en(mem_en),
        .mem_rd_wr(mem_rd_wr),
        .mem_to_reg(mem_to_reg),
        .ALUOp(ALUOp),
        .Cin(Cin),
        .invA(invA),
        .invB(invB),
        .sign(sign)
    );

    dff pipeline_ID_EX [291:0] (
        .clk(clk),
        .rst(rst),
        .d({
            rs1,
            rs2,
            rd,
            data1,
            data2,
            imm_out,
            LUI,
            J,
            B,
            JALR,
            SET,
            Cin,
            invA,
            invB,
            sign,
            reg_write,
            mem_en,
            mem_rd_wr,
            mem_to_reg,
            ALUOp,
            pc_IF_ID,
            instr_IF_ID,
            rf_data1_out,
            rf_data2_out,
            B_J_pc,
            off_src,
			R,
			AUIPC,
            stall,
            S
        }),
        .q({
            rs1_ID_EX,
            rs2_ID_EX,
            rd_ID_EX,
            data1_ID_EX,
            data2_ID_EX,
            imm_out_ID_EX,
            LUI_ID_EX,
            J_ID_EX,
            B_ID_EX,
            JALR_ID_EX,
            SET_ID_EX,
            Cin_ID_EX,
            invA_ID_EX,
            invB_ID_EX,
            sign_ID_EX,
            reg_write_ID_EX,
            mem_en_ID_EX,
            mem_rd_wr_ID_EX,
            mem_to_reg_ID_EX,
            ALUOp_ID_EX,
            pc_ID_EX,
            instr_ID_EX,
            rf_data1_ID_EX,
            rf_data2_ID_EX,
            B_J_pc_ID_EX,
            B_J_ID_EX,
			R_ID_EX,
			AUIPC_ID_EX,
            stall_ID_EX,
            S_ID_EX
        })
    );

endmodule
`default_nettype wire
