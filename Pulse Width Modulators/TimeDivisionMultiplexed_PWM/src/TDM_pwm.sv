module tdm_pwm_64bit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic [63:0] target_in, // Input to update a specific channel
    input  logic [3:0]  update_idx,
    input  logic        update_en,
    output logic [15:0] pwm_bus
);
    logic [3:0]  led_idx;
    logic [127:0] context_ram [16]; // {count[63:0], target[63:0]}
    
    logic [63:0] c_count, c_target;
    logic [63:0] n_count;
    logic        match;

    // 1. Scheduler
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) led_idx <= 0;
        else if (en) led_idx <= led_idx + 1'b1;
    end

    // 2. Read Context
    assign {c_count, c_target} = context_ram[led_idx];

    // 3. Shared Engine (Counter + Comparison)
    // We increment count and compare against target
    assign n_count = (c_count >= 64'hFFFF_FFFF_FFFF_FFFF) ? 64'd0 : (c_count + 1'b1);
    assign match   = (c_count < c_target);

    // 4. Write Context & Output Hold
    always_ff @(posedge clk) begin
        if (en) begin
            // If the user wants to update a target, we do it when led_idx matches
            if (update_en && (led_idx == update_idx)) begin
                context_ram[led_idx] <= {n_count, target_in};
            end else begin
                context_ram[led_idx] <= {n_count, c_target};
            end
            
            pwm_bus[led_idx] <= match;
        end
    end
endmodule
