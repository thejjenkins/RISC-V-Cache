`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2025 03:24:52 PM
// Design Name: 
// Module Name: tb_MultiCache_4Way_Random
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module tb_MultiCache_4Way_Random();

  logic clk = 0;
  logic rst = 1;  // Reset logic
  logic ivalid = 0;
  logic iRW = 0;
  logic [10:0] iaddress;
  logic [7:0] iRAM32 [0:31];
  logic [7:0] iwrite_data;
  logic L1miss, ovalid;
  logic [7:0] oread_data;
  logic [31:0] hit_count, miss_count, total_accesses;

  // Instantiate MultiCache for 4-way with random replacement
  MultiCache #(.WAY_COUNT(4), .USE_RANDOM_REPLACEMENT(1)) DUT (
    .clk(clk),
    .rst(rst),
    .ivalid(ivalid),
    .iRW(iRW),
    .iaddress(iaddress),
    .iRAM32(iRAM32),
    .iwrite_data(iwrite_data),
    .L1miss(L1miss),
    .ovalid(ovalid),
    .oread_data(oread_data),
    .hit_count(hit_count),
    .miss_count(miss_count),
    .total_accesses(total_accesses)
  );

  // Clock generation
  always #10 clk = ~clk;

  // Initialize dummy memory
  initial begin
    for (int i = 0; i < 32; i++)
      iRAM32[i] = 8'hE0 + i;
  end

  // Reset pulse
  initial begin
    rst = 1;
    #25;
    rst = 0;
  end

  // Test sequence
  initial begin
    #30;
    ivalid = 1;

    // Fill all 4 ways at index 5
    iaddress = 11'b001_0101_0000; #20;
    iaddress = 11'b010_0101_0000; #20;
    iaddress = 11'b011_0101_0000; #20;
    iaddress = 11'b100_0101_0000; #20;

    // Trigger random replacement
    iaddress = 11'b101_0101_0000; #20;

    // Re-access to evaluate hit/miss
    iaddress = 11'b001_0101_0000; #20;
    iaddress = 11'b010_0101_0000; #20;
    iaddress = 11'b011_0101_0000; #20;
    iaddress = 11'b100_0101_0000; #20;
    iaddress = 11'b101_0101_0000; #20;

    ivalid = 0;
    #40;

    $display("\n==== 4-Way Cache (Random Replacement) ====");
    $display("Total Accesses : %0d", total_accesses);
    $display("Hits           : %0d", hit_count);
    $display("Misses         : %0d", miss_count);

    if (total_accesses > 0) begin
      automatic real hit_rate = hit_count * 1.0 / total_accesses;
      automatic real miss_rate = miss_count * 1.0 / total_accesses;
      automatic real amat = 1.0 + (miss_rate * 100.0);
      $display("Hit Rate       : %.2f", hit_rate);
      $display("Miss Rate      : %.2f", miss_rate);
      $display("AMAT           : %.2f cycles", amat);
    end

    $stop;
  end

endmodule
