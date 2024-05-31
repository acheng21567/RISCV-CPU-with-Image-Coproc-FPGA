// /////////////////////////////////////////////////////////////////////////////
// Program: Debouncer.sv
// 
// Project: ECE 554 COPROC
// 
// Author: Team Sachima
// 
// Description:
//  - Debouncer module that debounces the button input
// 
//  - Inputs:
//     clk: 	            Global clock signal for 25MHz
//     rst_n: 	            Global active low reset
//     button_in: 	        Button input signal
// 
//  - Outputs:
//     button_pulse: 	    Debounced button pulse signal
// /////////////////////////////////////////////////////////////////////////////

module Debouncer (
    input logic clk,
    input logic rst_n, 
    input logic button_in,
    output logic button_pulse
);
    ////////////////////////////////////////////////////////////
    ///////// Local Param & Internal Signal Declaration ////////
    ////////////////////////////////////////////////////////////
    localparam DEBOUNCE_TIME = 250000;
    logic [17:0] cnt;
    logic sync0, sync1, last_stable_button, button_stable;

    ////////////////////////////////////////////////////////////
    ///////////////////// Module Operation /////////////////////
    ////////////////////////////////////////////////////////////

    // Synchronize the button input by double flopping
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            sync0 <= 0;
            sync1 <= 0;
        end 
        else begin
            sync0 <= button_in;
            sync1 <= sync0;
        end
    end

    // Wait for the button to be stable for DEBOUNCE_TIME before updating the stable value
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            cnt <= 0;
            button_stable <= 0;
        end 
        else if (sync1 == button_stable) begin
            cnt <= 0;
        end 
        else begin
            cnt <= cnt + 1;
            if (cnt >= DEBOUNCE_TIME) begin
                button_stable <= sync1;
                cnt <= 0;
            end
        end
    end

    // Generate a pulse when the button is pressed
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            button_pulse <= 0;
            last_stable_button <= 0;
        end 
        else begin
            if (button_stable & ~last_stable_button)
                button_pulse <= 1;
            else
                button_pulse <= 0;

            last_stable_button <= button_stable;
        end
    end


endmodule
