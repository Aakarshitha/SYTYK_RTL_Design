/////////////////////////////////////////
////Author: Aakarshitha////
/////////////////////////////////////////

module blinking_pwm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       pwm_out
);

    // State Encoding
    typedef enum logic [1:0] {
        ST_IDLE = 2'b00,
        ST_HIGH = 2'b01,
        ST_LOW  = 2'b10
    } state_t;

    // Registers (The _q suffix denotes "output of Flop")
    state_t      state_q, state_nxt;
    logic [5:0]  count_q, count_nxt; // 6 bits to handle up to 2N (32)
    logic [4:0]  duty_q,  duty_nxt;  // N value (1 to 16)

    // Process 1: Sequential Logic (Flops)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= ST_IDLE;
            count_q <= 0;
            duty_q  <= 1;
        end else if (en) begin
            state_q <= state_nxt;
            count_q <= count_nxt;
            duty_q  <= duty_nxt;
        end
    end

    // Process 2: Next State Logic
    // Using 0 to N-1 convention
    logic [5:0] target;
    assign target = (state_q == ST_HIGH) ? (duty_q - 1) : ((duty_q << 1) - 1);

    always_comb begin
        state_nxt = state_q;
        case (state_q)
            ST_IDLE: if (en) state_nxt = ST_HIGH;
            ST_HIGH: if (count_q == target) state_nxt = ST_LOW;
            ST_LOW:  if (count_q == target) state_nxt = ST_HIGH;
            default: state_nxt = ST_IDLE;
        endcase
    end

    // Process 3: Datapath Logic (Counter and Duty updates)
    always_comb begin
        count_nxt = count_q;
        duty_nxt  = duty_q;

        if (count_q == target) begin
            count_nxt = 0;
            // Increment duty only when completing a full cycle (End of ST_LOW)
            if (state_q == ST_LOW) begin
                duty_nxt = (duty_q == 16) ? 1 : duty_q + 1;
            end
        end else begin
            count_nxt = count_q + 1;
        end
    end

    // Glitch-free Output (Direct from Register)
    assign pwm_out = (state_q == ST_HIGH);

endmodule
