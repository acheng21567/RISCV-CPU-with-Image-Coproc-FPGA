// Tested should be okay to run?
module addr_calc_DMA(
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic we_in,                      // No need?
    output logic re,
    output logic we_out,
    output logic [6:0] raddr0,
    output logic [6:0] raddr1,
    output logic [6:0] raddr2,
    output logic [8:0] waddr,
    output logic [7:0] col_cnt,
    output logic [2:0] row_sel_onehot       // each bit is used to increment the row address read for each bank
);

    // logic [1:0] bank_sel;

    // increment column counter to select center pixels for reads and writes
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            col_cnt <= '0;
        end
        else if (start) begin
            col_cnt <= '0;
        end 
        else begin
            col_cnt <= col_cnt + 1;
        end
    end

    // select which read row address should be incremented across the banks
    always_ff @(posedge clk, negedge rst_n) begin
        // TODO: to be tested, need to think about initial value
        if (~rst_n) begin
            row_sel_onehot <= 3'b001;
        end
        else if (start) begin
            row_sel_onehot <= 3'b001;
        end
        else if (~(|col_cnt)) begin
            row_sel_onehot <= {row_sel_onehot[1:0], row_sel_onehot[2]};
        end
    end

    // read addresses
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            raddr0 <= '0;
            raddr1 <= '0;
            raddr2 <= '0;
        end
        else if (start) begin
            raddr0 <= '0;
            raddr1 <= '0;
            raddr2 <= '0;
        end
        // TODO: to be tested, need to test timing
        else if (col_cnt == 8'd255 & row_sel_onehot[0]) begin
            raddr0 <= raddr0 + 1;
        end
        else if (col_cnt == 8'd255 & row_sel_onehot[1]) begin
            raddr1 <= raddr1 + 1;
        end
        else if (col_cnt == 8'd255 & row_sel_onehot[2]) begin
            raddr2 <= raddr2 + 1;
        end
    end

    // // logic to enable bank write
    // always_ff @(posedge clk, negedge rst_n) begin
    //     if (~rst_n) begin
    //         bank_write <= 0;
    //     end
    //     else if (start) begin
    //         bank_write <= 0;
    //     end
    //     else if (&col_cnt) begin
    //         bank_write <= 1;
    //     end
    // end

    // // enable we to image buffer when col_cnt == 255
    // // TODO: to be tested
    // assign we_out = bank_write & (&col_cnt);


    logic [6:0] bank_waddr;
    
    // write address calculation
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            bank_waddr <= '1;
        end
        else if (start) begin
            bank_waddr <= '0;
        end
        else if (row_sel_onehot[2] & (~|col_cnt)) begin
            bank_waddr <= bank_waddr + 1;
        end
    end


    
    assign we_out = ~(|col_cnt);
    // TODO: to be tested
    assign re = start | ~(|col_cnt);
    // TODO: to be tested
    assign waddr = {row_sel_onehot[2:1], bank_waddr};

endmodule