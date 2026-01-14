// Code your design here
module pipelined_pwm_64bit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [63:0] target,
    output logic        pwm_out
);
    logic [63:0] count_q;
    logic [3:0]  pipe_match_q;
    logic        final_match_q;
    
    // Pre-calculate adjusted target to compensate for 4-stage pipeline lag
    logic [63:0] adj_target;
    assign adj_target = target - 64'd2;// -2 so that it accounts for the 4 stage lag due to pipeline where  the other two comes from the two registers pipematchq and finalmatchq calculated . so +4 -2 -2 = 0 lag!

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q <= 0;
            pwm_out <= 0;
        end else if (en) begin
            // Pulse is HIGH from 0 until the match is detected
            if (final_match_q) begin
                count_q <= 0;
                pwm_out <= 0;
            end else begin
                count_q <= count_q + 1;
                if (count_q == 0) pwm_out <= 1; 
            end
        end
    end

    // Pipelined Equality Check
    always_ff @(posedge clk) begin
        pipe_match_q[0] <= (count_q[15:0]  == adj_target[15:0]);
        pipe_match_q[1] <= (count_q[31:16] == adj_target[31:16]);
        pipe_match_q[2] <= (count_q[47:32] == adj_target[47:32]);
      // pipe_match_q[3] <= (count_q[63:48] == adj_target[63:48]);//was this earlier
        pipe_match_q[3] <= (count_q[63:48] == adj_target[63:48]);
        final_match_q   <= &pipe_match_q;
    end
endmodule
