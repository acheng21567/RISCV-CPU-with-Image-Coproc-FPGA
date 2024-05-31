//////////////////////////////////////////////////////////////////////////////////
// Project: GroupProject
// Module: UART_boot_tb
// Description: Top-Level Device Testbench for validation of UART Bootloader & I/O interaction
//////////////////////////////////////////////////////////////////////////////////

module Bootload_tb();
    // Import Common Parameters Package
    import common_params::*;

    ////////////////////////////////////////////////////////////
    ////////////////////////// DUT /////////////////////////////
    ////////////////////////////////////////////////////////////

    // DUT Signals
    logic clk, rst_n;
    logic [15:0] wdata_addr;
    logic [IB_DW - 1 : 0] wdata_data;
    logic [7:0] tx_data;
    logic TX_TRSMT, RX;
    logic tx_done, bootloading;
    logic [2:0] dst;
    logic [BITS - 1 : 0] IO_WDATA, IO_ADDR;
    logic HLT, IO_WEN, IO_RDEN;
    logic [BITS - 1 : 0] IO_RDATA, expected_data;

    localparam baud_rate = 13'h01B2;
    integer p = 0;

    logic [15:0] expected_addr;
    logic [7:0] test_data_im [0:13] = { 
                                8'h04, // write to instr_mem
                                8'h00, // pc addr 0
                                8'h00,
                                8'h93, // addi x1,x0,0x0101
                                8'h00,
                                8'h10,
                                8'h10,

                                8'h04, // write to instr_mem
                                8'h01, // pc addr 1
                                8'h00,
                                8'h13, // addi x2,x1,0xfffff800
                                8'h81,
                                8'h00,
                                8'h80
                            };
    
    logic [7:0] test_data_dm [0:27] = { 8'h02, // write to dm_mem
                                8'hA0,
                                8'h01, // mem addr 0x01A0
                                8'h55,
                                8'h00,
                                8'h00, 
                                8'h00, // Dummy Data: 0x0055

                                8'h02, // write to dm_mem
                                8'h01,
                                8'h00, // mem addr 0x0001
                                8'h42,
                                8'h00, // Dummy Data: 0x0042
                                8'h00,
                                8'h00,

                                8'h02, //write to dm_mem
                                8'hC2,
                                8'h00, //mem addr 0x00C2
                                8'h21,
                                8'h03,  // Dummy Data: 0x0321
                                8'h00,
                                8'h00,

                                8'h02, //write to dm_mem
                                8'h36,
                                8'h00, //mem addr 0x00C2
                                8'hB1,
                                8'h0C,  // Dummy Data: 0x0CB1
                                8'h00,
                                8'h00
                            };

    // DUT Instantiations
    UART_TX iTX(.clk(clk), .rst_n(rst_n), .trmt(TX_TRSMT), .tx_data(tx_data), .TX(RX),
				.tx_done(tx_done), .baud_DB(baud_rate), .ACK_TRMT());

    UART_boot iDUT(.clk(clk), .rst_n(rst_n), .RX(RX), .wdata_data(wdata_data), .wdata_addr(wdata_addr), 
        .dst(dst), .bootloading(bootloading)); 

    CPU iCPU(.clk(clk), .rst_n(rst_n & ~bootloading), .HLT(HLT), .IO_WDATA(IO_WDATA),
		.IO_RDATA(IO_RDATA), .IO_ADDR(IO_ADDR), .IO_WEN(IO_WEN),
		.IO_RDEN(IO_RDEN), .wdata_data(wdata_data[IB_DW - 1 : IB_DW - BITS]), .wdata_addr(wdata_addr), 
		.bootloading(bootloading), .dst(dst));

    ////////////////////////////////////////////////////////////
    ///////////////////// Clock Generation /////////////////////
    ////////////////////////////////////////////////////////////
    always #5 clk = ~clk;

    ////////////////////////////////////////////////////////////
    /////////////////// Stimulus Generation ////////////////////
    ////////////////////////////////////////////////////////////
    initial begin
        // Default Values & Initiate Reset Sequence
		clk = 1'b0;
		rst_n = 1'b0;
        TX_TRSMT = 1'b0;
        tx_data = 8'h00;

        // Deassert Reset
		repeat(2)@(negedge clk);
		rst_n = 1'b1;


        ///////////////////////////////
        //  test bootloading to dm  //
        /////////////////////////////

        //send data
        for (integer i = 0; i < 28; i = i + 1) begin
            tx_data = test_data_dm[i];
            TX_TRSMT = 1;
            @(posedge clk);
            TX_TRSMT = 0;
            
            @(posedge tx_done);
            @(posedge clk);
        end

        p = 0;
        //first data package
        if(iCPU.MEM.d_mem.BANK0.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+3]) begin
            $display("first data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK1.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+4]) begin
            $display("first data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK2.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+5]) begin
            $display("first data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK3.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+6]) begin
            $display("storing 16'h0055 to dm at 16'h0A10 is wrong");
            $stop();
        end

        p = p + 7;
        //second data package
        if(iCPU.MEM.d_mem.BANK0.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+3]) begin
            $display("ADDR %h",{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]});
            $display("DATA %h", test_data_dm[p+3]);
            $display("second data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK1.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+4]) begin
            $display("second data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK2.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+5]) begin
            $display("second data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK3.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+6]) begin
            $display("second data package is wrong");
            $stop();
        end

        p = p + 7;
        //third data package
        if(iCPU.MEM.d_mem.BANK0.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+3]) begin
            $display("third data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK1.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+4]) begin
            $display("third data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK2.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+5]) begin
            $display("third data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK3.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+6]) begin
            $display("third data package is wrong");
            $stop();
        end

        p = p + 7;
        //forth data package
        if(iCPU.MEM.d_mem.BANK0.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+3]) begin
            $display("forth data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK1.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+4]) begin
            $display("forth data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK2.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+5]) begin
            $display("forth data package is wrong");
            $stop();
        end
        if(iCPU.MEM.d_mem.BANK3.RAM[{1'b0, {test_data_dm[p+2], test_data_dm[p+1]}[14:2]}] !== test_data_dm[p+6]) begin
            $display("forth data package is wrong");
            $stop();
        end

        $display("All tests for bootloading to dm passed!");

        ///////////////////////////////
        //  test bootloading to im  //
        /////////////////////////////
        
        //send data
        for (integer i = 0; i < 14; i = i + 1) begin
            tx_data = test_data_im[i];
            TX_TRSMT = 1;
            @(posedge clk);
            TX_TRSMT = 0;
            
            @(posedge tx_done);
            @(posedge clk);
        end

        p = 0;
        if(iCPU.IF.i_mem.instr_mem[0] !== {test_data_im[p+6], test_data_im[p+5], test_data_im[p+4], test_data_im[p+3]}) begin
            $display("addi x1,x0,0x0101 did not load correctly");
            $stop();
        end

        p = p + 7;
        if(iCPU.IF.i_mem.instr_mem[1] !== {test_data_im[p+6], test_data_im[p+5], test_data_im[p+4], test_data_im[p+3]}) begin
            $display("addi x2,x1,0xfffff800 did not load correctly");
            $stop();
        end

        //extra clock cycles for processor to run instructions`
        repeat(20)@(posedge clk);

        if(iCPU.ID.rf.REG_BANK[1] !== 32'h0101) begin
            $display("addi x1,x0,0x0101 did not run correctly");
        end
        if(iCPU.ID.rf.REG_BANK[2] !== 32'h0101 + 32'hfffff800) begin
            $display("addi x2,x1,0xfffff800 did not run correctly");
        end

        $display("All tests for bootloading to im passed!");
        $display("Yahoo!");
		$stop();
    end

endmodule
