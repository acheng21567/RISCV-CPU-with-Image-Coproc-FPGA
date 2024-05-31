// /////////////////////////////////////////////////////////////////////////////
// Program: image_buffer.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Image buffer module that stores 2 images of 256*256 pixels
// 
//  - Inputs:
//     clk: 	Global clock signal for 25MHz
//     waddr [8:0]: 	9-bit write address for the image buffer
//     raddr [8:0]: 	9-bit Read address for the image buffer
//     we: 	Write enable for writing to specified waddr
//     wdata: 	3072-bit write data to be written in to the address specified by waddr
// 
//  - Outputs:
//     rdata: 	3072-bit read data reading out from the address specified by raddr
// /////////////////////////////////////////////////////////////////////////////

module image_buffer(
    input logic clk,
    input logic [8:0] raddr,
    input logic [8:0] waddr,
    input logic we,
    input logic [3071:0] wdata,
    output logic [3071:0] rdata,

    input logic [3071:0] wdata_boot,
    input logic [8:0] waddr_boot,
    input logic we_boot,
    input logic bootloading
);

    logic write_en;
    logic [3071:0] write_data;
    logic [8:0] write_addr;

    assign write_en = (bootloading)? we_boot : we & waddr[8];
    assign write_addr = (bootloading)? waddr_boot : waddr;
    assign write_data = (bootloading)? wdata_boot : wdata;


	////////////////////////////////////////////////////////////
    /////////////////// Module Instantiation ///////////////////
    ////////////////////////////////////////////////////////////
    
    // Instantiate the big image buffer to store 2 images
    img_buf512x3072 iIMAGES(
        .clk(clk), .we(write_en), .waddr(write_addr), .raddr(raddr),
        .wdata(write_data), .rdata(rdata));

endmodule