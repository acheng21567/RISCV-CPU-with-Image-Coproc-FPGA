`default_nettype none
module fetch (
    input wire clk,
    input wire rst,
    input wire [31:0] B_J_pc_EX,
    input wire B_J_EX,
    input wire [31:0] instr_curr,
    input wire lw_stall,
    input wire br_stall,

    output wire [31:0] pc_IF_ID,
    output wire [31:0] instr_IF_ID, curr_pc
);

    wire [31:0] next_pc, pc_plus_4;
    wire cla0_out, cla1_out;
    wire ECALL;
    wire [31:0] pc_to_IF_ID;
    wire stall;

    assign stall = lw_stall | br_stall;

    cla16b iCLA [1:0] (.sum(next_pc), .cOut({cla1_out, cla0_out}), .inA(curr_pc), .inB(32'h00000004), .cIn({cla0_out, 1'b0}), .sign(1'b0), .Ofl());

    assign curr_pc = B_J_EX ? B_J_pc_EX : pc_to_IF_ID;

    assign ECALL = instr_curr[6:0] == 7'h73;
    reg32 pc_reg(.clk(clk), .rst(rst), .d(next_pc), .q(pc_to_IF_ID), .writeEn(~ECALL & ~stall));
    reg32 pc_IF_ID_reg(.clk(clk), .rst(rst), .d(curr_pc), .q(pc_IF_ID), .writeEn(~stall));
    reg32 instr_reg(.clk(clk), .rst(rst), .d(instr_curr), .q(instr_IF_ID), .writeEn(~stall));

endmodule
`default_nettype wire