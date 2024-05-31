module image_buffer(
    input logic clk,
    input logic [8:0] raddr,
    input logic [8:0] waddr,
    input logic we,
    input logic [3071:0] wdata,
    output logic [3071:0] rdata
);

    img_buf512x3072 iIMAGES(
        .clk(clk), .we(we & waddr[8]), .waddr(waddr), .raddr(raddr),
        .wdata(wdata), .rdata(rdata));

endmodule