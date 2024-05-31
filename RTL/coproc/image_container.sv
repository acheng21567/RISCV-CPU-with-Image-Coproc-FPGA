module image_container 
#(  
    parameter LOAD_MEM = 0
)
(
    input logic clk,
    input logic rst_n,
    input logic [6:0] raddr0,
    input logic [6:0] raddr1,
    input logic [6:0] raddr2,
    input logic [8:0] waddr,
    input logic re,
    input logic we,
    input logic [3071:0] wdata,
    output logic [3071:0] rdata0,
    output logic [3071:0] rdata1,
    output logic [3071:0] rdata2
);
    logic bank0_64_we, bank1_64_we, bank2_64_we;
    logic bank0_32_we, bank1_32_we, bank2_32_we;
    logic [3071:0] rdata0_64, rdata1_64, rdata2_64;
    logic [3071:0] rdata0_32, rdata1_32, rdata2_32;


    image_bank_64_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(0)) 
    image_bank0_64 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr0[5:0]),
        .waddr(waddr[5:0]),
        .re(re),
        .we(bank0_64_we),
        .rdata(rdata0_64),
        .wdata(wdata)
    );

    image_bank_64_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(1)) 
    image_bank1_64 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr1[5:0]),
        .waddr(waddr[5:0]),
        .re(re),
        .we(bank1_64_we),
        .rdata(rdata1_64),
        .wdata(wdata)
    );

    image_bank_64_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(2)) 
    image_bank2_64 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr2[5:0]),
        .waddr(waddr[5:0]),
        .re(re),
        .we(bank2_64_we),
        .rdata(rdata2_64),
        .wdata(wdata)
    );

    image_bank_32_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(0)) 
    image_bank0_32 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr0[4:0]),
        .waddr(waddr[4:0]),
        .re(re),
        .we(bank0_32_we),
        .rdata(rdata0_32),
        .wdata(wdata)
    );

    image_bank_32_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(1)) 
    image_bank1_32 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr1[4:0]),
        .waddr(waddr[4:0]),
        .re(re),
        .we(bank1_32_we),
        .rdata(rdata1_32),
        .wdata(wdata)
    );

    image_bank_32_rows #(.LOAD_MEM(LOAD_MEM), .HEX_IDX(2)) 
    image_bank2_32 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(raddr2[4:0]),
        .waddr(waddr[4:0]),
        .re(re),
        .we(bank2_32_we),
        .rdata(rdata2_32),
        .wdata(wdata)
    );

    assign rdata0 = raddr0[6] ? rdata0_32 : rdata0_64;
    assign rdata1 = raddr1[6] ? rdata1_32 : rdata1_64;
    assign rdata2 = raddr2[6] ? rdata2_32 : rdata2_64;


    // Write enable for each bank, only one bank should be written to
    assign bank0_64_we = we & (waddr[8:6] == 3'b000);
    assign bank1_64_we = we & (waddr[8:6] == 3'b010);
    assign bank2_64_we = we & (waddr[8:6] == 3'b100);

    assign bank0_32_we = we & (waddr[8:5] == 4'b0010);
    assign bank1_32_we = we & (waddr[8:5] == 4'b0110);
    assign bank2_32_we = we & (waddr[8:5] == 4'b1010);
    

endmodule