module img_buf512x3072(clk,we,waddr,raddr,rdata,wdata);

  input clk,we;
  input [8:0] waddr,raddr;
  input [3071:0] wdata;
  output reg [3071:0] rdata;

  img_buf512x640 #(.HEX_IDX("4")) iPART0(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[639:0]),.wdata(wdata[639:0]));
  img_buf512x640 #(.HEX_IDX("3")) iPART1(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[1279:640]),.wdata(wdata[1279:640]));
  img_buf512x640 #(.HEX_IDX("2")) iPART2(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[1919:1280]),.wdata(wdata[1919:1280]));
  img_buf512x640 #(.HEX_IDX("1")) iPART3(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[2559:1920]),.wdata(wdata[2559:1920]));
  img_buf512x512 #(.HEX_IDX("0")) iPART4(.clk(clk),.we(we),.waddr(waddr),.raddr(raddr), .rdata(rdata[3071:2560]),.wdata(wdata[3071:2560]));

endmodule                        
                        