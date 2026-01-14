module fibonacci_shared_adder (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       pwm_out
);
    logic [7:0] count_q, fib_curr_q, fib_prev_q;
    logic       state_q; 
    logic [7:0] op_a, op_b, sum;

    assign sum = op_a + op_b;

    // --- SHARED ADDER MUX ---
    always_comb begin
        if (count_q == 8'd1) begin
            op_a = fib_curr_q;
            // If prev is our special start flag (FF), add 0 to stay at 1.
            op_b = (fib_prev_q == 8'hFF) ? 8'd0 : fib_prev_q;
        end else begin
            op_a = count_q;
            op_b = 8'hFF; // -1
        end
    end

    // --- SEQUENTIAL LOGIC ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q    <= 8'd1;
            fib_curr_q <= 8'd1;
            fib_prev_q <= 8'hFF; // Special "First 1" flag
            state_q    <= 1'b1;  // Start in LOW
            pwm_out    <= 1'b0;
        end else if (en) begin
            if (count_q <= 8'd1) begin
                state_q <= ~state_q;
                
                // Set pwm_out based on the state we are ENTERING
                // If entering state 0, pwm_out goes HIGH
                pwm_out <= (state_q == 1'b1); 

                if (state_q == 1'b1) begin // Entering HIGH Phase
                    if (fib_prev_q == 8'hFF) begin
                        // Transition from First 1 to Second 1
                        fib_curr_q <= 8'd1;
                        fib_prev_q <= 8'd0; // Now 1+0 will happen next
                        count_q    <= 8'd1; 
                    end else begin
                        // Standard Fibonacci Update
                        fib_curr_q <= (sum > 255) ? 8'd1 : sum;
                        fib_prev_q <= fib_curr_q;
                        count_q    <= (sum > 255) ? 8'd1 : sum;
                    end
                end else begin // Entering LOW Phase
                    count_q <= fib_curr_q;
                end
            end else begin
                count_q <= sum;
            end
        end else begin
            pwm_out <= 1'b0;
        end
    end
endmodule
