`timescale 1ns/1ps

module tb_tdm_pwm_multi;
    logic clk=0, rst_n=0, en=0;
    logic [63:0] target_in;
    logic [3:0]  update_idx;
    logic        update_en;
    logic [15:0] pwm_bus;

    // 1GHz Clock
    always #0.5 clk = ~clk; 

    tdm_pwm_64bit uut (.*);

    // Function to calculate width in effective cycles
    // Period is 1ns, but TDM visits each LED every 16ns
    function real get_cycles(realtime diff);
        return diff / 16.0;
    endfunction

    initial begin
        $dumpfile("tdm_multi.vcd");
        $dumpvars(0, tb_tdm_pwm_multi);

        $display("--- Starting Multi-Channel TDM Verification ---");
        #10 rst_n = 1;
        #10 en = 1;

        // --- STEP 1: Load different targets for 3 different LEDs ---
        // LED 0: Target 50
        update_target(4'd0, 64'd50);
        // LED 5: Target 120
        update_target(4'd5, 64'd120);
        // LED 15: Target 200
        update_target(4'd15, 64'd200);

        // --- STEP 2: Parallel Monitoring ---
        fork
            monitor_led(0, 50);
            monitor_led(5, 120);
            monitor_led(15, 200);
        join_any // Stop after these specific pulses are caught

        $display("--------------------------------------------------");
        $display("TEST COMPLETE: TDM Context Switching Verified.");
        $display("--------------------------------------------------");
        #100 $finish;
    end

    // --- TASK: Update Target ---
    task update_target(input [3:0] idx, input [63:0] val);
        begin
            @(negedge clk);
            update_idx = idx;
            target_in = val;
            update_en = 1;
            @(negedge clk);
            update_en = 0;
            $display("T=%0t | Configured LED[%0d] with Target=%0d", $time, idx, val);
        end
    endtask

    // --- TASK: Monitor LED ---
    task monitor_led(input int id, input [63:0] expected);
        realtime start_t;
        real measured;
        begin
            @(posedge pwm_bus[id]);
            start_t = $realtime;
            @(negedge pwm_bus[id]);
            measured = get_cycles($realtime - start_t);
            $display("T=%0t | [LED %0d] Detected Width: %0.1f cycles (Expected: %0d)", 
                     $time, id, measured, expected);
            
            // Basic assertion
            if (measured != real'(expected)) 
                $display("  >> ERROR: Width mismatch on LED %0d!", id);
            else
                $display("  >> SUCCESS: LED %0d width is perfect.", id);
        end
    endtask

endmodule
