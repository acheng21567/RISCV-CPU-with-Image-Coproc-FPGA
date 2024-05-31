`default_nettype none
module execute (
    input wire clk,
    input wire rst,
    input wire [31:0] data1,
    input wire [31:0] data2,
    input wire J, B, JALR, R, AUIPC, S,
    input wire Cin, invA, invB, sign,
    input wire [2:0] Oper,
    input wire SET,
    input wire [31:0] rf_data1,
    input wire [31:0] instr_ID_EX_original, pc_ID_EX,
    input wire [31:0] imm_out_ID_EX,
    input wire LUI_ID_EX, mem_to_reg_ID_EX,
    input wire [4:0] rd_ID_EX,
    input wire mem_en_ID_EX, mem_rd_wr_ID_EX,
    input wire [31:0] rf_data2_ID_EX_original,
    input wire reg_write_ID_EX,

    input wire [4:0] rs1_ID_EX, rs2_ID_EX,

    input wire [31:0] alu_result_EX_forward, alu_result_MEM_forward,
    input wire reg_write_EX_forward, reg_write_MEM_forward,
    input wire [4:0] rd_EX_forward, rd_MEM_forward,

    input wire [4:0] rs1_ID, rs2_ID,
    input wire stall, cond_for_lw_stall,


    // input wire [31:0] alu_result_MEM_forward,


    output wire [31:0] alu_result_EX_MEM,
    output wire [31:0] instr_EX_MEM, pc_EX_MEM,
    output wire [31:0] imm_out_EX_MEM,
    output wire LUI_EX_MEM, mem_to_reg_EX_MEM,
    output wire [4:0] rd_EX_MEM,
    output wire mem_en_EX_MEM, mem_rd_wr_EX_MEM,
    output wire [31:0] rf_data2_EX_MEM,
    output wire reg_write_EX_MEM,
    output wire lw_stall_EX_MEM,
    output wire lw_stall
);
    wire off_src, cla0_out, cla1_out;
    wire [31:0] pc_offset, pc_addr_src, pc_sum;
    wire [31:0] alu_result;


    // InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl
    

    // cla16b iCLA [1:0] (.sum(pc_sum), .cOut({cla1_out, cla0_out}), .inA(pc_addr_src), .inB(pc_offset), .cIn({cla0_out, 1'b0}), .sign(1'b0), .Ofl());

    // assign off_src = J | (take_branch & B);
    // assign pc_offset = off_src ? imm_out_ID_EX : 32'h00000004;
    // assign pc_addr_src = JALR ? rf_data1 : pc_ID_EX;

    // assign B_J_pc = JALR ? {pc_sum[31:2], 2'b00} : pc_sum;

    wire [31:0] alu_in1, alu_in2, instr_ID_EX, rf_data2_ID_EX;
    wire forward_X_X, forward_M_X;

    assign instr_ID_EX = stall ? 32'h0 : instr_ID_EX_original;
    // assign instr_ID_EX = stall ? 32'h0 : instr_ID_EX_original;
    
    alu iALU(.InA(alu_in1), .InB(alu_in2), .Cin(Cin), .Oper(Oper), .invA(invA), .invB(invB), .sign(sign), .Out(alu_result), .func3(instr_ID_EX[14:12]), .SET(SET));


    assign forward_M_X = (rd_MEM_forward != 0) & reg_write_MEM_forward;
    assign forward_X_X = (rd_EX_forward != 0) & reg_write_EX_forward;
    assign alu_in1 = (forward_X_X & (rs1_ID_EX == rd_EX_forward) & ~J & ~AUIPC) ? alu_result_EX_forward : (forward_M_X & (rs1_ID_EX == rd_MEM_forward) & ~J & ~AUIPC) ? alu_result_MEM_forward : data1;
    assign alu_in2 = (forward_X_X & (rs2_ID_EX == rd_EX_forward) & (R | B)) ? alu_result_EX_forward : (forward_M_X & (rs2_ID_EX == rd_MEM_forward) & (R | B)) ? alu_result_MEM_forward : data2;


    assign lw_stall = ~stall & mem_en_ID_EX & ~mem_rd_wr_ID_EX & ((rs1_ID == rd_ID_EX) | (rs2_ID == rd_ID_EX)) & cond_for_lw_stall;

    // HM
    assign rf_data2_ID_EX = (forward_X_X & (rs2_ID_EX == rd_EX_forward) & (S)) ? alu_result_EX_forward : (forward_M_X & (rs2_ID_EX == rd_MEM_forward) & (S)) ? alu_result_MEM_forward : rf_data2_ID_EX_original;

    dff pipeline_EX_MEM [170:0] (
        .clk(clk),
        .rst(rst),
        .d({alu_result, instr_ID_EX, pc_ID_EX, imm_out_ID_EX, LUI_ID_EX, mem_to_reg_ID_EX, rd_ID_EX, mem_en_ID_EX & ~stall, mem_rd_wr_ID_EX & ~stall, rf_data2_ID_EX, reg_write_ID_EX & ~stall, lw_stall}),
        .q({alu_result_EX_MEM, instr_EX_MEM, pc_EX_MEM, imm_out_EX_MEM, LUI_EX_MEM, mem_to_reg_EX_MEM, rd_EX_MEM, mem_en_EX_MEM, mem_rd_wr_EX_MEM, rf_data2_EX_MEM, reg_write_EX_MEM, lw_stall_EX_MEM})
    );

endmodule
`default_nettype wire
