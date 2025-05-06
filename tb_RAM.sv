`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Computer Architecture
// Final Project: Two-Level Cache Hierarchy Simulation
// Module: tb_RAM
// Due 05/06/2025
//  
// James Jenkins, PhD student, Elec. Engr., Howard University
// Chase Adams, undergraduate, Comp. Engr., Howard University
// Instructor: Hassan Salmani, PhD.
//////////////////////////////////////////////////////////////////////////////////


module tb_RAM();
    logic clk;
    logic rst;            // Reset signal
    logic RW;             // 0 = read, 1 = write (unused for now)
    logic valid;          // Triggers memory access
    logic [10:0] address; // 11-bit address
    logic [7:0] write_data; // unused
    logic [7:0] read_data;  // Result from memory
    logic ready;           // High after 100 cycles

    // Instantiate the DUT
    RAM DUT (
        .clk(clk),
        .rst(rst),
        .RW(RW),
        .valid(valid),
        .address(address),
        //.write_data(write_data), // Include this if in your module
        .read_data(read_data),
        .ready(ready)
    );

    // Clock generation: 50MHz (20ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Main test logic
    initial begin
        // Reset
        rst = 1;
        valid = 0;
        RW = 0;
        address = 11'd1706; // 11'b11010101010
        write_data = 8'h00;

        #30; // hold reset for 30ns
        rst = 0;

        // Wait a little, then issue read request
        #20;
        valid = 1;
        // Wait for memory ready
        wait (ready == 1);
     
        valid = 0;

        #100;
        $stop;
    end
endmodule
