module smoke_test;
    logic clk=0, rst_n=0, en=0;
    logic pwm_out;

    // Change module name here to test different versions
    pipelined_pwm_64bit uut (.*);

    always #5 clk = ~clk;

    initial begin
        $display("Starting Test...");
        #20 rst_n = 1;
        #20 en = 1; 
        
        // Check first 3 pulses
        repeat(3) begin
            @(posedge pwm_out);
            $display("T=%0t | PWM HIGH detected", $time);
            @(negedge pwm_out);
            $display("T=%0t | PWM LOW detected", $time);
        end
        
        #100 en = 0;
        $display("T=%0t | Enable dropped. PWM should stay LOW.", $time);
        #100 $finish;
    end
endmodule
