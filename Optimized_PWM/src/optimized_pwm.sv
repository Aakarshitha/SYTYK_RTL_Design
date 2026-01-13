module optimized_shadow_pwm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic [7:0] cpu_data_in,
    input  logic       cpu_update,
    output logic       pwm_out
);
    logic [7:0] n_shadow_q, n_active_q, count_q;

    always_ff @(posedge clk) if (cpu_update) n_shadow_q <= cpu_data_in;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q <= 0;
            n_active_q <= 8'd10;
        end else if (en) begin
            if (count_q == 0) begin
                count_q    <= n_active_q;
                n_active_q <= n_shadow_q; // Safe update at boundary
            end else begin
                count_q <= count_q - 1;
            end
        end
    end
    assign pwm_out = en && (count_q != 0); 
endmodule
