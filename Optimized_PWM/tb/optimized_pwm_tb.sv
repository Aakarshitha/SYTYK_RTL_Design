`timescale 1ns/1ps

module tb_optimized_shadow_pwm;
    logic       clk = 0;
    logic       rst_n = 0;
    logic       en = 0;
    logic [7:0] cpu_data_in = 8'd20; // Start with N=20
    logic       cpu_update = 0;
    logic       pwm_out;

    always #5 clk = ~clk; // 100MHz

    optimized_shadow_pwm uut (.*);

    initial begin
        $dumpfile("optimized.vcd");
        $dumpvars(0, tb_optimized_shadow_pwm);
        
        $display("--- Optimized Shadow PWM Smoke Test ---");
        #20 rst_n = 1;
        #20 en = 1;

        // Wait until counter is mid-way (e.g., at 10)
        #60; 
        
        // Update N to 5 mid-cycle
        cpu_data_in = 8'd5;
        cpu_update  = 1;
        #10 cpu_update = 0;
        $display("T=%0t | CPU requested N=5 mid-cycle. Active N should remain 20.", $time);

        // Monitor Active Register transition
        // In GTKWave, watch 'uut.n_active_q'
        repeat(2) begin
            @(negedge pwm_out);
            $display("T=%0t | Frame finished. Active N is now: %0d", $time, uut.n_active_q);
        end

        #200 $finish;
    end
endmodule
