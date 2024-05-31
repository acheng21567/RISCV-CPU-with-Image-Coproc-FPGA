module Debouncer (
    input wire clk,          // Clock input
    input wire rst_n,        // Asynchronous reset, active low
    input wire button_in,    // Noisy button input
    output reg button_out    // Debounced button output
);
    // Parameters
    parameter DEBOUNCE_TIME = 250000; // Number of clk cycles for debouncing (~10ms at 25MHz clock)
    
    // Registers
    reg [17:0] stable_counter = 0;  // Enough to count up to DEBOUNCE_TIME
    reg button_sync_0, button_sync_1;  // For synchronizing the button input to the clock

    // Synchronize the button input to avoid metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_sync_0 <= 0;
            button_sync_1 <= 0;
        end else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stable_counter <= 0;
            button_out <= 0;
        end else if (button_sync_1 == button_out) begin
            // If current stable state matches the output, reset counter
            stable_counter <= 0;
        end else begin
            // If states do not match, increment counter
            stable_counter <= stable_counter + 1;
            if (stable_counter >= DEBOUNCE_TIME) begin
                // If counter exceeds debounce time, change output state
                button_out <= button_sync_1;
                stable_counter <= 0;  // Reset counter
            end
        end
    end
endmodule
