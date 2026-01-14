`timescale 1ns/1ps

module tb_fib_breathing;

    // --- Signals ---
    logic clk = 0;
    logic rst_n = 0;
    logic en = 0;
    logic pwm_out;

    // --- UUT Instantiation ---
    fibonacci_shared_adder uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .en     (en),
        .pwm_out(pwm_out)
    );

    // --- Clock Generation (100MHz) ---
    always #5 clk = ~clk;

    // --- Logic to Measure Pulse Widths ---
    realtime rising_edge_time;
    realtime pulse_width;

    // --- Stimulus & VCD Dumping ---
    initial begin
        $dumpfile("fib_test.vcd");
        $dumpvars(0, tb_fib_breathing);
        
        $display("--------------------------------------------------");
        $display("STARTING FIBONACCI SMOKE TEST");
        $display("Goal: Verify pulse widths follow 1, 1, 2, 3, 5...");
        $display("--------------------------------------------------");

        // Reset and Enable
        #20 rst_n = 1;
        #20 en = 1;

      // Monitor first 7 Fibonacci pulses
      repeat (9) begin
            @(posedge pwm_out);
            rising_edge_time = $realtime;
            
            @(negedge pwm_out);
            pulse_width = ($realtime - rising_edge_time) / 10; // Divide by clock period (10ns)
            
            $display("T=%0t | Detected HIGH Pulse Width: %0d cycles", $time, pulse_width);
        end

        $display("--------------------------------------------------");
        $display("TEST COMPLETE: Check if sequence matches Fibonacci.");
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
