module Debouncer (
    input logic clk,
    input logic rst_n, 
    input logic button_in,
    output logic button_pulse
);

    parameter DEBOUNCE_TIME = 250000;
    
    logic [17:0] cnt;
    logic sync0, sync1, last_stable_button, button_stable;

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
