module fibonacci_shared_adder (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       pwm_out
);
    logic [7:0] count_q, fib_curr_q, fib_prev_q;
    logic       state_q; 
    logic [7:0] op_a, op_b, sum;

    assign sum = op_a + op_b; // THE only adder

    always_comb begin
        if (count_q == fib_curr_q) begin
            op_a = fib_curr_q; op_b = fib_prev_q; // Fib Mode
        end else begin
            op_a = count_q;    op_b = 8'd1;       // Counter Mode
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q <= 0; fib_curr_q <= 1; fib_prev_q <= 0; state_q <= 0;
        end else if (en) begin
            if (count_q == fib_curr_q) begin
                count_q <= 0;
                state_q <= ~state_q;
                if (state_q) begin // End of LOW phase
                    fib_curr_q <= (sum > 255) ? 8'd1 : sum;
                    fib_prev_q <= fib_curr_q;
                end
            end else count_q <= sum;
        end
    end
    assign pwm_out = en && (state_q == 0);
endmodule
