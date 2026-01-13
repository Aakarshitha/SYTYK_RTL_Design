
module optimized_shadow_pwm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic [7:0] cpu_data_in,
    input  logic       cpu_update,
    output logic       pwm_out
);
    logic [7:0] n_shadow_q; 
    logic [7:0] n_active_q; 
    logic [7:0] count_q;

    // 1. Shadow Register: Always captures CPU data when update is pulsed
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            n_shadow_q <= 8'd0; // Default startup value
        else if (cpu_update) 
            n_shadow_q <= cpu_data_in;
    end

    // 2. Active Logic: Reset n_active_q to prevent X-propagation
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count_q    <= 8'd0;
            n_active_q <= 8'd0; // Must be initialized on reset!
        end else if (en) begin
            if (count_q == 0) begin
                // Load the pulse width for the NEXT frame
                count_q    <= n_shadow_q; 
                n_active_q <= n_shadow_q; 
            end else begin
                count_q <= count_q - 1;
            end
        end
    end

    assign pwm_out = en && (count_q != 0); 
endmodule
