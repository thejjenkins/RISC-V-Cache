`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Computer Architecture
// Final Project: Two-Level Cache Hierarchy Simulation
// Module: tb_CPU
// Due 05/06/2025
//  
// James Jenkins, PhD student, Elec. Engr., Howard University
// Chase Adams, undergraduate, Comp. Engr., Howard University
// Instructor: Hassan Salmani, PhD.
//////////////////////////////////////////////////////////////////////////////////

module tb_CPU();
    logic clk = 1'b0;
    logic iready, iRW, ovalid, L1miss, L2miss;
    logic [7:0] iread_data, owrite_data;
    logic [10:0] iaddress, oaddress;
    logic [10:0] random_addresses [0:9999];
    
    CPU DUT(
    .clk(clk),
    .iready(iready),
    .iRW(iRW),
    .ovalid(ovalid),
    .L1miss(L1miss),
    .L2miss(L2miss),
    .iaddress(iaddress),
    .oaddress(iaddress),
    .owrite_data(owrite_data),
    .iread_data(iread_data)
    );
    
    //  Resetting the system
    initial begin
        iRW = 1'b1;
        iready = 1'b1;
        iread_data = 8'hAA; // arbitrary test value
        L1miss = 0;
        L2miss = 0;
    end
    //  System clock 50MHz
    initial begin
        forever #10 clk = ~clk;
    end
    
    initial begin
        for (int i = 0; i < 10000; i++) begin
            random_addresses[i] = $urandom_range(0, 2047); // 11-bit max = 2^11 - 1 = 2047
        end
    end
    
    initial begin
//        for (int i = 0; i < 10000; i++) begin
//            oaddress = random_addresses[i];
//            #20;
//        end
        iaddress = random_addresses[0]; #20
        iaddress = random_addresses[1]; #20
        oaddress = random_addresses[2];
        iready = 0;                     #20
        iaddress = random_addresses[3]; #20
        iready = 1;
        iaddress = random_addresses[4]; #20
        iready = 0;
        iaddress = random_addresses[5]; #20
        iaddress = random_addresses[6]; #20
        iaddress = random_addresses[7]; #20
        iready = 1;
        iaddress = random_addresses[8]; #20
        iaddress = random_addresses[9];
    end
    
    // Stop
    initial begin
        #300 $stop;
        // Simulation for 2ns
    end
endmodule
