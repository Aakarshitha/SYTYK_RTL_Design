
module phased_tdm_pwm (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    output logic [15:0] pwm_bus
);
    logic [63:0] global_count_q;
    logic [63:0] context_ram_target [16];
    logic [63:0] phase_offsets [16];
    logic [3:0]  led_idx;

    // Initialization (Internal phases)
    initial begin
        for(int i=0; i<16; i++) begin
            phase_offsets[i] = i * 64'd1000; // Stagger every 1000 cycles
            context_ram_target[i] = 64'd500; // 500 cycle duty cycle
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            global_count_q <= 0;
            led_idx <= 0;
        end else if (en) begin
            global_count_q <= global_count_q + 1'b1;
            led_idx <= led_idx + 1'b1;
            
            // Logic: PWM is HIGH if count is between [phase] and [phase + target]
            pwm_bus[led_idx] <= (global_count_q >= phase_offsets[led_idx]) && 
                                (global_count_q < (phase_offsets[led_idx] + context_ram_target[led_idx]));
        end
    end
endmodule
