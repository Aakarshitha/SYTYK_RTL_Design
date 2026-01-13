`timescale 1ns/1ps

module tb_pipelined_pwm;
    logic        clk = 0;
    logic        rst_n = 0;
    logic        en = 0;
    logic [63:0] target = 64'd100; 
    logic        pwm_out;

    // Time tracking variables
    realtime rising_edge_time;
    realtime pulse_width;

    // 1GHz Clock (1.0ns period)
    always #0.5 clk = ~clk;

    pipelined_pwm_64bit uut (.*);

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, tb_pipelined_pwm);
        
        $display("--- Starting Pipelined PWM High-Speed Monitor ---");
        
        // Reset and Enable sequence
        #10 rst_n = 1;
        @(negedge clk); 
        en = 1;

        // Test with 3 different targets to verify pipeline stability
        // Target 1: 100 cycles
        // Target 2: 50 cycles
        // Target 3: 200 cycles
        for (int i = 0; i < 3; i++) begin
            if (i == 1) target = 64'd50;
            if (i == 2) target = 64'd200;

            repeat (2) begin // Check two pulses per target value
                @(posedge pwm_out);
                rising_edge_time = $realtime;
                
                @(negedge pwm_out);
                // Divide by 1.0 because the period is 1ns at 1GHz
                pulse_width = ($realtime - rising_edge_time) / 1.0;
                
                $display("T=%0t | Target: %0d | Detected HIGH Pulse Width: %0.1f cycles", 
                         $time, target, pulse_width);
            end
        end

        $display("--------------------------------------------------");
        $display("TEST COMPLETE: Verify pulse width matches target + latency.");
        $display("--------------------------------------------------");
        $finish;
    end
endmodule
