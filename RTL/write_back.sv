`default_nettype none
module write_back (
    input wire clk,
    input wire rst,
    input wire [31:0] alu_result,
    input wire [31:0] mem_result,
    input wire [31:0] immediate,
    input wire mem_to_reg,
    input wire LUI,
    output wire [31:0] write_data
);

    assign write_data = LUI ? immediate : (mem_to_reg ? mem_result : alu_result);

endmodule
`default_nettype wire