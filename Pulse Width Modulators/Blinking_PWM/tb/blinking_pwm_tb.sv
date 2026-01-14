// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module blinking_pwm_tb;

    // Signal Declaration
    logic clk;
    logic rst_n;
    logic en;
    logic pwm_out;

    // Instantiate the Unit Under Test (UUT)
    blinking_pwm uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .pwm_out (pwm_out)
    );

    // Clock Generation (100MHz -> 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // --- Setup ---
        $display("Starting Smoke Test...");
        $dumpfile("dump.vcd"); // For GTKWave or EDA Playground
        $dumpvars(0, blinking_pwm_tb);
        
        rst_n = 0;
        en = 0;
        
        // --- Reset Phase ---
        #25;
        rst_n = 1;
        #10;
        
        // --- Enable Design ---
        $display("T=%0t | Enabling PWM...", $time);
        en = 1;

        // --- Observe N=1 Cycle ---
        // Expect: 1 High, 2 Low
        wait(pwm_out == 1);
        $display("T=%0t | Cycle N=1 Started (PWM HIGH)", $time);
        wait(pwm_out == 0);
        $display("T=%0t | PWM flipped to LOW", $time);

        // --- Observe N=2 Cycle ---
        // Expect: 2 High, 4 Low
        wait(pwm_out == 1);
        $display("T=%0t | Cycle N=2 Started (PWM HIGH)", $time);
        
        // Let it run for a while to see the breathing progression
        #500;
        
        $display("T=%0t | Smoke Test Complete. Check Waveforms.", $time);
        $finish;
    end

endmodule
