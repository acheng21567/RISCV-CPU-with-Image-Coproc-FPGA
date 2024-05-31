module basic_ALU_tb();

// DUT Signal
logic [3:0] r_in, g_in, b_in;
logic [3:0] r_out, g_out, b_out;
logic [3:0] r_exp, g_exp, b_exp;
logic [1:0] func;
logic [11:0] max, min;

basic_ALU iALU(.pixel_in({r_in, g_in, b_in}), .func(func),
               .max(max), .min(min), .pixel_out({r_out, g_out, b_out}));

initial begin
    max = 12'hCCC;
    min = 12'h111;

    // Test inversion
    func = 2'b00;

    #10;

    for(int i = 0; i < 5'b10000; i++) begin
        for(int j = 0; j < 5'b10000; j++) begin
            for(int k = 0; k < 5'b10000; k++) begin
                #5;
                r_in = i[3:0];
                g_in = j[3:0];
                b_in = k[3:0];
                #5;
                if({r_out, g_out, b_out} !== {r_exp, g_exp, b_exp}) begin
                    $display("ERROR!");
                    $stop();
                end
            end
        end
    end

    #10;
    
    // Test coloring
    func = 2'b01;

    for(int i = 0; i < 5'b10000; i++) begin
        #5;
        r_in = i[3:0];
        g_in = i[3:0];
        b_in = i[3:0];
        #5;
        if({r_out, g_out, b_out} !== {r_exp, g_exp, b_exp}) begin
            $display("ERROR!");
            $stop();
        end
    end

    #10;

    // Test threshing
    func = 2'b11;

    for(int i = 0; i < 5'b10000; i++) begin
        for(int j = 0; j < 5'b10000; j++) begin
            for(int k = 0; k < 5'b10000; k++) begin
                #5;
                r_in = i[3:0];
                g_in = j[3:0];
                b_in = k[3:0];
                #5;
                if({r_out, g_out, b_out} !== {r_exp, g_exp, b_exp}) begin
                    $display("ERROR!");
                    $stop();
                end
            end
        end
    end

    #10;

    $stop();
end

always_comb begin
    case(func)
        2'b00: begin
            r_exp = ~r_in;
            g_exp = ~g_in;
            b_exp = ~b_in;
        end
        2'b01: begin
            if (g_in <= 4'b0010)
                {r_exp, g_exp, b_exp} = '0;
            else if (g_in <= 4'b0100)
                {r_exp, g_exp, b_exp} = 12'h00F;
            else if (g_in <= 4'b1001)
                {r_exp, g_exp, b_exp} = 12'h0F0;
            else if (g_in <= 4'b1101)
                {r_exp, g_exp, b_exp} = 12'hF00;
            else
                {r_exp, g_exp, b_exp} = '1;
        end
        2'b10: begin
            r_exp = r_in;
            g_exp = g_in;
            b_exp = b_in;
        end
        default: begin
            {r_exp, g_exp, b_exp} = {
                r_in > 4'b0111 ? 4'b1111 : 4'b0000,
                g_in > 4'b0111 ? 4'b1111 : 4'b0000,
                b_in > 4'b0111 ? 4'b1111 : 4'b0000
            };
        end
    endcase 
end



endmodule