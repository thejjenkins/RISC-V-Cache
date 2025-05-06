`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Computer Architecture
// Final Project: Two-Level Cache Hierarchy Simulation
// Module: RAM
// Due 05/06/2025
//  
// James Jenkins, PhD student, Elec. Engr., Howard University
// Chase Adams, undergraduate, Comp. Engr., Howard University
// Instructor: Hassan Salmani, PhD.
//////////////////////////////////////////////////////////////////////////////////


module RAM (
    //input logic L1miss,
    //input logic L2miss,
    input  logic clk,
    input  logic RW,               // 0 = read, 1 = write (future use)
    input  logic valid,            // triggers memory access
    input  [10:0] address,         // 11-bit address
    output logic [7:0] read_data,  // read result
    output logic ready             // goes high after 100 cycles
);

/*typedef enum logic[1:0] {

        IDLE = 2'b00,

        READING = 2'b01,

        WRITING = 2'b10
        //STATES FOR MEMORY 

    } state_t;

state_t state_reg, state_next;

*/
 
    logic [7:0] memory [0:2047];
    logic reading;
    logic [6:0] delay_counter;
    logic [10:0] addr_reg;
    
    
 always_ff @(posedge clk) begin
    if (~valid) begin
        delay_counter <= 0;
        ready <= 0;
        reading <= 0;
        addr_reg <= 0;
        read_data <= 8'h00;
    end else if (valid && !reading) begin
        addr_reg <= address;
        reading <= 1;
        delay_counter <= 0;
        ready <= 0;
    end else if (reading) begin
        if (delay_counter < 7'd100)
            delay_counter <= delay_counter + 1'b1;
        else begin
            delay_counter <= 0;
            reading <= 0;
            ready <= 1;
            read_data <= memory[addr_reg];
        end
    end else begin
        ready <= 0;
    end
end



//    initial begin
//     integer i;
//     for (i = 0; i < 2048; i = i + 1)
//        memory[i] = 8'h00;
//     memory[11'b11010101010] = 8'hB7;  // <- preload value at address 0x6AA
//    end

initial begin
    for (int i = 0; i < 2048; i++) begin
        memory[i] = $urandom_range(0, 256); // initialize each memory cell with random byte
    end
end

    
endmodule