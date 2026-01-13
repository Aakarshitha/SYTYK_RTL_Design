`timescale 1ns/1ps

module tb_pipelined_pwm;
    logic        clk = 0;
    logic        rst_n = 0;
    logic        en = 0;
    logic [63:0] target = 64'd100; // Testing with N=100
    logic        pwm_out;

    // 1GHz Clock (1ns period)
    always #0.5 clk = ~clk;

    pipelined_pwm_64bit uut (.*);

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, tb_pipelined_pwm);
        
        $display("--- Pipelined PWM Smoke Test (1GHz) ---");
        #10 rst_n = 1;
        #10 en = 1;

        // Measure pulse width
        @(posedge pwm_out);
        $display("T=%0t | Pulse Started", $time);
        @(negedge pwm_out);
        $display("T=%0t | Pulse Ended. Width should be 100ns.", $time);

        #500 $finish;
    end
endmodule
