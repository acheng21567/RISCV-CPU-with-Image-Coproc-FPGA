module img_buf512x512
#(  
    parameter string HEX_IDX = "0"
)
(clk,we,waddr,raddr,rdata,wdata);
  
  input clk,we;
  input [8:0] waddr,raddr;
  input [511:0] wdata;
  output reg [511:0] rdata;
  
  // localparam base_path = "C:/Users/asus/Desktop/ECE554/ECE554-SP24/Final_Project/COPROC/hex_files/IMG_PART";
  localparam base_path = "I:/ECE554/Project/ECE554-SP24/Final_Project/COPROC/hex_files/IMG_PART";

  
  reg [511:0]mem10k[0:511];
  
  always @(posedge clk) begin
    if (we)
      mem10k[waddr] <= wdata;
    rdata <= mem10k[raddr];
  end

  initial begin
    $readmemh({base_path, HEX_IDX, ".hex"}, mem10k); 
  end
  
endmodule
  