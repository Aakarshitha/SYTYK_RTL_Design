
module rgb_pipelined_pwm (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [63:0] r_target, g_target, b_target,
    output logic        r_out, g_out, b_out
);
    logic [63:0] count_q;
    // Pipeline Stages
    logic [2:0]  pipe_match_s1_q; // [R, G, B]
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) count_q <= 0;
        else        count_q <= count_q + 1'b1;
    end

    // Stage 1: Comparison
    always_ff @(posedge clk) begin
        pipe_match_s1_q[2] <= (count_q < r_target);
        pipe_match_s1_q[1] <= (count_q < g_target);
        pipe_match_s1_q[0] <= (count_q < b_target);
    end

    // Stage 2: Registered Output
    always_ff @(posedge clk) begin
        {r_out, g_out, b_out} <= pipe_match_s1_q;
    end
endmodule
