`default_nettype none
module core (

input wire i_clk,                                        // clock to the design
input wire i_rst,                                        // Reset to the design : Active High

//I -cache interface
input wire [31 : 0] i_instr,                               // Instruction word
input wire i_icache_done,                                  // Icache Done. No Need to worry for DRAMIdeal
output wire o_instr_mem_rd,                                // Instruction Mem Read. Tie to 1'b1 for simplicity.
output wire [31 : 0] o_instr_mem_addr,                     // 32 bit Instruction address

//D-cache interface
input wire [31 : 0] i_data_mem_out,                        // Data read from Data Memory
input wire i_dcache_done,                                  // Dcache Done. No Need to worry for DRAMIdeal
output wire [31 : 0] o_data_mem_addr,                      // Data Mem address
output wire o_data_mem_en,                                 // Data Mem Enable
output wire o_data_mem_rd_wr,                              // Data Mem Read Write Strobe, 1'b0 : Read strobe, 1'b1 Write Strobe
output wire [31 : 0] o_data_mem_in,                        // Data written to Data Memory

//Ecall   - Indicate end of the code
output wire o_ecall                                        // Ecall taken from Writeback stage in case of pipe design. Without this all tests fail
 

);


/* Include your code here. Instantiate fetch  : u_fetch_stage, decode : u_decode_stage, execute : u_execute_stage, memory : u_memory_stage, write_back : u_write_back_stage, register_file : u_register_file modules with given instance names */

wire [31 : 0] write_data, B_J_pc_EX_MEM;
wire LUI, J, B, JALR, S, Cin, invA, invB, sign, SET, R, AUIPC;
wire [2 : 0] ALUOp;

wire [31:0] instr_IF_ID, instr_ID_EX, instr_EX_MEM, instr_MEM_WB;
wire [31:0] pc_IF_ID, pc_ID_EX, pc_EX_MEM, pc_MEM_WB;
wire B_J_EX_MEM;
wire [4:0] rs1_ID_EX, rs1_EX_MEM, rs1_MEM_WB;
wire [4:0] rs2_ID_EX, rs2_EX_MEM, rs2_MEM_WB;
wire [4:0] rd_ID_EX, rd_EX_MEM, rd_MEM_WB;
wire LUI_ID_EX, LUI_EX_MEM, LUI_MEM_WB;
wire reg_write_ID_EX, reg_write_EX_MEM, reg_write_MEM_WB;
wire mem_en_ID_EX, mem_en_EX_MEM, mem_en_MEM_WB;
wire mem_rd_wr_ID_EX, mem_rd_wr_EX_MEM, mem_rd_wr_MEM_WB;
wire mem_to_reg_ID_EX, mem_to_reg_EX_MEM, mem_to_reg_MEM_WB;
wire [31:0] data1_ID_EX, data2_ID_EX, rf_data1_ID_EX, rf_data2_ID_EX, rf_data1_out, rf_data2_out;
wire [31:0] imm_out_ID_EX, imm_out_EX_MEM, imm_out_MEM_WB;
wire [31:0] alu_result_EX_MEM, alu_result_MEM_WB;
wire [31:0] rf_data2_EX_MEM;
wire [31:0] mem_data_out_MEM_WB;
wire [4:0] rf_rs1, rf_rs2;
wire [31:0] curr_pc;
wire B_J_EX;
wire [31:0] B_J_pc_EX;
wire lw_stall, stall_ID_EX;

assign o_instr_mem_rd = 1'b1;
assign o_instr_mem_addr = {curr_pc[31:2], 2'b00};

assign o_data_mem_addr = {alu_result_EX_MEM[31:2], 2'b00};
assign o_data_mem_en = mem_en_EX_MEM;
assign o_data_mem_in = rf_data2_EX_MEM;
assign o_data_mem_rd_wr = mem_rd_wr_EX_MEM;

assign o_ecall = (instr_MEM_WB[6:0] == 7'h73);

wire lw_stall_EX_MEM, cond_for_lw_stall, br_stall;

// wire [31:0] alu_result_MEM_forward;
// assign alu_result_MEM_forward = mem_to_reg_MEM_WB ? mem_data_out_MEM_WB : alu_result

fetch u_fetch_stage (
    .clk(i_clk),
    .rst(i_rst),
    .B_J_pc_EX(B_J_pc_EX),
    .B_J_EX(B_J_EX),
    .pc_IF_ID(pc_IF_ID),
    .instr_curr(i_instr),
    .lw_stall(lw_stall),
    .br_stall(br_stall),

    .instr_IF_ID(instr_IF_ID),
    .curr_pc(curr_pc)
);

register_file u_register_file (
    .clk(i_clk),
    .rst(i_rst),
    .read1RegSel(rf_rs1),
    .read2RegSel(rf_rs2),
    .writeRegSel(rd_MEM_WB),
    .writeInData(write_data),
    .writeEn(reg_write_MEM_WB),
    .read1OutData(rf_data1_out),
    .read2OutData(rf_data2_out),
    .err()
);

decode u_decode_stage (
    .clk(i_clk),
    .rst(i_rst),
    .instr_IF_ID_original(instr_IF_ID),
    .rf_data1_out(rf_data1_out),
    .rf_data2_out(rf_data2_out),
    .pc_IF_ID(pc_IF_ID),
    .B_J_EX(B_J_EX),
    .lw_stall(lw_stall),
    .alu_result_EX_forward(alu_result_EX_MEM),
    .alu_result_MEM_forward(write_data),
    .reg_write_EX_forward(reg_write_EX_MEM),
    .reg_write_MEM_forward(reg_write_MEM_WB),
    .rd_EX_forward(rd_EX_MEM),
    .rd_MEM_forward(rd_MEM_WB),


    .rs1_ID_EX(rs1_ID_EX),
    .rs2_ID_EX(rs2_ID_EX),
    .rd_ID_EX(rd_ID_EX),
    .data1_ID_EX(data1_ID_EX),
    .data2_ID_EX(data2_ID_EX),
    .imm_out_ID_EX(imm_out_ID_EX),
    .LUI_ID_EX(LUI_ID_EX),
    .J_ID_EX(J),
    .B_ID_EX(B),
	.R_ID_EX(R),
    .S_ID_EX(S),
	.AUIPC_ID_EX(AUIPC),
    .JALR_ID_EX(JALR),
    .SET_ID_EX(SET),
    .Cin_ID_EX(Cin),
    .invA_ID_EX(invA),
    .invB_ID_EX(invB),
    .sign_ID_EX(sign),
    .ALUOp_ID_EX(ALUOp),
    .reg_write_ID_EX(reg_write_ID_EX),
    .mem_en_ID_EX(mem_en_ID_EX),
    .mem_rd_wr_ID_EX(mem_rd_wr_ID_EX),
    .mem_to_reg_ID_EX(mem_to_reg_ID_EX),
    .pc_ID_EX(pc_ID_EX),
    .instr_ID_EX(instr_ID_EX),
    .rs1(rf_rs1),
    .rs2(rf_rs2),
    .rf_data1_ID_EX(rf_data1_ID_EX),
    .rf_data2_ID_EX(rf_data2_ID_EX),
    .B_J_pc_ID_EX(B_J_pc_EX),
    .B_J_ID_EX(B_J_EX),
    .stall_ID_EX(stall_ID_EX),
    .cond_for_lw_stall(cond_for_lw_stall),
    .br_stall(br_stall)
);

execute u_execute_stage (
    .clk(i_clk),
    .rst(i_rst),
    .data1(data1_ID_EX),
    .data2(data2_ID_EX),
    .J(J),
    .B(B),
    .JALR(JALR),
    .S(S),
    .Cin(Cin),
    .invA(invA),
    .invB(invB),
    .sign(sign),
    .Oper(ALUOp),
    .SET(SET),
    .rf_data1(rf_data1_ID_EX),
    .instr_ID_EX_original(instr_ID_EX),
    .pc_ID_EX(pc_ID_EX),
    .imm_out_ID_EX(imm_out_ID_EX),
    .LUI_ID_EX(LUI_ID_EX),
    .mem_to_reg_ID_EX(mem_to_reg_ID_EX),
    .rd_ID_EX(rd_ID_EX),
    .mem_en_ID_EX(mem_en_ID_EX),
    .mem_rd_wr_ID_EX(mem_rd_wr_ID_EX),
    .rf_data2_ID_EX_original(rf_data2_ID_EX),
    .reg_write_ID_EX(reg_write_ID_EX),
	.R(R),
	.AUIPC(AUIPC),
    .rs1_ID_EX(rs1_ID_EX),
    .rs2_ID_EX(rs2_ID_EX),
    .alu_result_EX_forward(alu_result_EX_MEM),
    .alu_result_MEM_forward(write_data),
    .reg_write_EX_forward(reg_write_EX_MEM),
    .reg_write_MEM_forward(reg_write_MEM_WB),
    .rd_EX_forward(rd_EX_MEM),
    .rd_MEM_forward(rd_MEM_WB),
    .rs1_ID(rf_rs1), 
    .rs2_ID(rf_rs2),
    .stall(lw_stall_EX_MEM),
    .cond_for_lw_stall(cond_for_lw_stall),


    .alu_result_EX_MEM(alu_result_EX_MEM),
    .instr_EX_MEM(instr_EX_MEM),
    .pc_EX_MEM(pc_EX_MEM),
    .imm_out_EX_MEM(imm_out_EX_MEM),
    .LUI_EX_MEM(LUI_EX_MEM),
    .mem_to_reg_EX_MEM(mem_to_reg_EX_MEM),
    .rd_EX_MEM(rd_EX_MEM),
    .mem_en_EX_MEM(mem_en_EX_MEM),
    .mem_rd_wr_EX_MEM(mem_rd_wr_EX_MEM),
    .rf_data2_EX_MEM(rf_data2_EX_MEM),
    .reg_write_EX_MEM(reg_write_EX_MEM),
    .lw_stall_EX_MEM(lw_stall_EX_MEM),
    .lw_stall(lw_stall)
);

memory u_memory_stage (
    .clk(i_clk),
    .rst(i_rst),
    .LUI_EX_MEM(LUI_EX_MEM),
    .mem_to_reg_EX_MEM(mem_to_reg_EX_MEM),
    .pc_EX_MEM(pc_EX_MEM),
    .instr_EX_MEM(instr_EX_MEM),
    .mem_data_out(i_data_mem_out),
    .alu_result_EX_MEM(alu_result_EX_MEM),
    .imm_out_EX_MEM(imm_out_EX_MEM),
    .rd_EX_MEM(rd_EX_MEM),
    .reg_write_EX_MEM(reg_write_EX_MEM),

    .LUI_MEM_WB(LUI_MEM_WB),
    .mem_to_reg_MEM_WB(mem_to_reg_MEM_WB),
    .alu_result_MEM_WB(alu_result_MEM_WB),
    .mem_data_out_MEM_WB(mem_data_out_MEM_WB),
    .imm_out_MEM_WB(imm_out_MEM_WB),
    .pc_MEM_WB(pc_MEM_WB),
    .instr_MEM_WB(instr_MEM_WB),
    .rd_MEM_WB(rd_MEM_WB),
    .reg_write_MEM_WB(reg_write_MEM_WB)
);

write_back u_write_back_stage(
    .clk(i_clk), 
    .rst(i_rst), 
    .alu_result(alu_result_MEM_WB), 
    .mem_result(mem_data_out_MEM_WB), 
    .immediate(imm_out_MEM_WB),
    .mem_to_reg(mem_to_reg_MEM_WB),
    .LUI(LUI_MEM_WB),
    .write_data(write_data)
);

endmodule
`default_nettype wire
