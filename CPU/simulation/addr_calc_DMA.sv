module addr_calc_DMA(
    input logic clk,
    input logic rst_n,
    input logic start,
    output logic we_img_buf,
    output logic [7:0] raddr,
    output logic [8:0] waddr,
    output logic [7:0] col_cnt,
    output logic [2:0] reg_sel,
    output logic done,
    output logic rdy,
    output logic reg2_rst,
    output logic cnt_start,
    output logic re
);

    logic [7:0] row_cnt;

    typedef enum logic [2:0] { IDLE, READ_START, COMP, READ, WRITE } state_t;
    state_t state, nxt_state;

    always @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

    always_comb begin
        nxt_state = state;
        cnt_start = 0;
        re = 0;
        we_img_buf = 0;
        done = 0;
        rdy = 0;

        case (state)
            READ_START: begin
                re = 1;
                cnt_start = 1;
                nxt_state = COMP;
            end
            COMP: begin
                if (~|row_cnt & ~waddr[8]) begin
                    done = 1;
                    rdy = 0;
                    nxt_state = IDLE;
                end
                else if (&col_cnt) begin
                    nxt_state = READ;
                end
            end
            READ: begin
                re = 1;
                nxt_state = WRITE;
            end
            WRITE: begin
                we_img_buf = 1;
                nxt_state = COMP;
            end
            default: begin
                if (start) begin
                    re = 1;
                    nxt_state = READ_START;
                end
                else begin                
                    rdy = 1;
                end
            end
        endcase
    end

    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            row_cnt <= '0;
        end
        else if (start) begin
            row_cnt <= '1;
        end
        else if (cnt_start) begin
            row_cnt <= row_cnt + 1;
        end
        else if (&col_cnt) begin
            row_cnt <= row_cnt + 1;
        end
    end

    // increment column counter to select center pixels for reads and writes
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            col_cnt <= '0;
        end
        else if (cnt_start) begin
            col_cnt <= '0;
        end 
        else if (cnt_start) begin
            col_cnt <= '0;
        end
        else begin
            col_cnt <= col_cnt + 1;
        end
    end

    // read addresses
    always_ff @(negedge clk, negedge rst_n) begin
        if (~rst_n) begin
            raddr <= '0;
        end
        else if (start) begin
            raddr <= '0;
        end
        else if (re) begin
            raddr <= raddr + 1;
        end
    end

    // select which read row address should be incremented across the banks
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            reg_sel <= 3'b010;
        end
        else if (start) begin
            reg_sel <= 3'b010;
        end
        else if (re) begin
            reg_sel <= {reg_sel[1:0], reg_sel[2]};
        end
    end
    
    // write addresses
    always_ff @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            waddr <= 9'h100;
        end
        else if (start) begin
            waddr <= 9'h100;
        end
        else if (we_img_buf) begin
            waddr <= waddr + 1;
        end
    end

    assign reg2_rst = &row_cnt;

endmodule