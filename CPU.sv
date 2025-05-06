`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Computer Architecture
// Final Project: Two-Level Cache Hierarchy Simulation
// Module: CPU
// Due 05/06/2025
//  
// James Jenkins, PhD student, Elec. Engr., Howard University
// Chase Adams, undergraduate, Comp. Engr., Howard University
// Instructor: Hassan Salmani, PhD.
//////////////////////////////////////////////////////////////////////////////////

module CPU(
    // inputs
    input logic clk, iready, iRW, L1miss, L2miss,
    input [7:0] iread_data,
    input [10:0] iaddress,
    // outputs
    output logic ovalid,
    output [10:0] oaddress,
    output [7:0] owrite_data
    );
    
typedef enum logic[1:0] {
    IDLE = 2'b00,
    READING = 2'b01,
    WRITING = 2'b10,
    HALT = 2'b11
} state_t;
state_t state_reg, state_next;

always_ff @(posedge clk) begin
    if (iready && (~L1miss || ~L2miss)) begin
        state_reg <= state_next;
    end else if (~iready && (L1miss || L2miss)) begin
        state_reg <= HALT;
    end else begin
        state_reg <= IDLE;
    end
end

always_comb begin
    state_next = state_reg;
    case (state_reg)
        IDLE : begin
            if (iready && iRW) begin
                state_next = READING;
            end else if (iready && ~iRW) begin
                state_next = WRITING;
            end
        end
        READING : begin
            ovalid = 1;
            // take iaddress every clock cycle;
        end
        WRITING : begin
            ovalid = 1;
            // not implemented for this project
        end
        HALT : begin
            
        end
    endcase
end
    
endmodule
