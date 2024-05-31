module image_bank_64_rows
#(  
    parameter HEX_IDX = 3,
    parameter LOAD_MEM = 0
)
(
    input logic clk,
    input logic rst_n,
    input logic [5:0] raddr,
    input logic [5:0] waddr,
    input logic re,
    input logic we,
    input logic [3071:0] wdata,
    output logic [3071:0] rdata
);

    // Image bank
    (* ramstyle = "mlab" *) logic [3071:0] bank [0:63];

    // Write enable
    always_ff @(posedge clk) begin
        if (we) begin
            bank[waddr] <= wdata;
        end
    end

    // Read enable
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            rdata <= '0;
        end
        else
        if (re) begin
            rdata <= bank[raddr];
        end
    end

    // Load test.hex to image bank for testing purpose
    // initial begin
    //     if (LOAD_MEM == 1)
    //         if (HEX_IDX == 0)
    //             $readmemh("I:/ECE554/Testing/Bank0_64.hex", bank);
    //         else if (HEX_IDX == 1)
    //             $readmemh("I:/ECE554/Testing/Bank1_64.hex", bank);
    //         else if (HEX_IDX == 2)
    //             $readmemh("I:/ECE554/Testing/Bank2_64.hex", bank);
    // end

    initial begin
        if (LOAD_MEM == 1)
            if (HEX_IDX == 0)
                $readmemh("C:/Users/asus/Desktop/ECE554/ECE554-SP24/Final_Project/RTL/coproc/hex/Bank0_64.hex", bank);
            else if (HEX_IDX == 1)
                $readmemh("C:/Users/asus/Desktop/ECE554/ECE554-SP24/Final_Project/RTL/coproc/hex/Bank1_64.hex", bank);
            else if (HEX_IDX == 2)
                $readmemh("C:/Users/asus/Desktop/ECE554/ECE554-SP24/Final_Project/RTL/coproc/hex/Bank2_64.hex", bank);
    end

endmodule