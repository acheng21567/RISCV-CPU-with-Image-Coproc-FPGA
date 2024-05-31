`default_nettype none
module memory (
    input wire clk,
    input wire rst,
    input wire LUI_EX_MEM, mem_to_reg_EX_MEM,
    input wire [31:0] pc_EX_MEM, instr_EX_MEM,
    input wire [31:0] mem_data_out, alu_result_EX_MEM, imm_out_EX_MEM,
    input wire [4:0] rd_EX_MEM,
    input wire reg_write_EX_MEM,


    output wire LUI_MEM_WB, mem_to_reg_MEM_WB,
    output wire [31:0] alu_result_MEM_WB, mem_data_out_MEM_WB, imm_out_MEM_WB,
    output wire [31:0] pc_MEM_WB, instr_MEM_WB,
    output wire [4:0] rd_MEM_WB,
    output wire reg_write_MEM_WB
);
    
    dff pipeline_MEM_WB [167:0] (
        .clk(clk),
        .rst(rst),
        .d({LUI_EX_MEM, mem_to_reg_EX_MEM, pc_EX_MEM, instr_EX_MEM, mem_data_out, alu_result_EX_MEM, imm_out_EX_MEM, rd_EX_MEM, reg_write_EX_MEM}),
        .q({LUI_MEM_WB, mem_to_reg_MEM_WB, pc_MEM_WB, instr_MEM_WB, mem_data_out_MEM_WB, alu_result_MEM_WB, imm_out_MEM_WB, rd_MEM_WB, reg_write_MEM_WB})
    );

endmodule
`default_nettype wire