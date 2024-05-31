/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit register file.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
`default_nettype none
module register_file (
           // Outputs
           read1OutData, read2OutData, err,
           // Inputs
           clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn
           );

   parameter WIDTH = 32;
   parameter SELBITS = 5;
   parameter INPUTLEN = WIDTH + 3*SELBITS + 3;

   input wire       clk, rst;
   input wire [SELBITS-1:0] read1RegSel;
   input wire [SELBITS-1:0] read2RegSel;
   input wire [SELBITS-1:0] writeRegSel;
   input wire [WIDTH-1:0] writeInData;
   input wire        writeEn;

   output wire [WIDTH-1:0] read1OutData;
   output wire [WIDTH-1:0] read2OutData;
   output wire        err;

   /* YOUR CODE HERE */
   wire [WIDTH-1:0] write_dec;
   rf_decode writeRegSelDec (.rd(writeRegSel), .reg_write(writeEn), .write_dec(write_dec));
   wire [WIDTH-1:0] data31, data30, data29, data28, data27, data26, data25, data24, data23, data22, data21, data20, data19, data18, data17, data16, data15, data14, data13, data12, data11, data10, data9, data8, data7, data6, data5, data4, data3, data2, data1, data0;
   wire [WIDTH - 1:0] gprs[32];
   //reg32 regs [WIDTH-1 : 0] (.q(gprs), 
   //                        .d(writeInData), .clk(clk), .rst(rst), .writeEn(write_dec));

   assign read1OutData = (read1RegSel != 0) & (read1RegSel == writeRegSel) & writeEn ? writeInData : gprs[read1RegSel];
   assign read2OutData = (read2RegSel != 0) & (read2RegSel == writeRegSel) & writeEn ? writeInData : gprs[read2RegSel];

   reg32 regs [WIDTH-1:0] (.q({data31, data30, data29, data28, data27, data26, data25, data24, data23, data22, data21, data20, data19, data18, data17, data16, data15, data14, data13, data12, data11, data10, data9, data8, data7, data6, data5, data4, data3, data2, data1, data0}), 
                            .d(writeInData), .clk(clk), .rst(rst), .writeEn(write_dec));

	assign gprs[31] = data31;
	assign gprs[30] = data30;
	assign gprs[29] = data29;
	assign gprs[28] = data28;
	assign gprs[27] = data27;
	assign gprs[26] = data26;
	assign gprs[25] = data25;
	assign gprs[24] = data24;
	assign gprs[23] = data23;
	assign gprs[22] = data22;
	assign gprs[21] = data21;
	assign gprs[20] = data20;
	assign gprs[19] = data19;
	assign gprs[18] = data18;
	assign gprs[17] = data17;
	assign gprs[16] = data16;
	assign gprs[15] = data15;
	assign gprs[14] = data14;
	assign gprs[13] = data13;
	assign gprs[12] = data12;
	assign gprs[11] = data11;
	assign gprs[10] = data10;
	assign gprs[9] = data9;
	assign gprs[8] = data8;
	assign gprs[7] = data7;
	assign gprs[6] = data6;
	assign gprs[5] = data5;
	assign gprs[4] = data4;
	assign gprs[3] = data3;
	assign gprs[2] = data2;
	assign gprs[1] = data1;
	assign gprs[0] = data0;



endmodule
`default_nettype wire
