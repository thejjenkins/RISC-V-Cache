`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2025 03:11:01 AM
// Design Name: 
// Module Name: tb_Multicache_2way_LRU
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


module tb_MultiCache_2Way_LRU();

  logic clk = 0;
  logic rst = 1;  // <-- Added reset
  logic ivalid = 0;
  logic iRW = 0;
  logic [10:0] iaddress;
  logic [7:0] iRAM32 [0:31];
  logic [7:0] iwrite_data;
  logic L1miss, ovalid;
  logic [7:0] oread_data;
  logic [31:0] hit_count, miss_count, total_accesses;

  // Instantiate 2-way cache with LRU
  MultiCache #(.WAY_COUNT(2), .USE_RANDOM_REPLACEMENT(0)) DUT (
    .clk(clk),
    .rst(rst),  // <-- Connected reset
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

  // Clock generator
  always #10 clk = ~clk;

  // Fill RAM32 with dummy values
  initial begin
    for (int i = 0; i < 32; i++) begin
      iRAM32[i] = 8'hC0 + i;
    end
  end

  // Reset pulse
  initial begin
    rst = 1;
    #25;
    rst = 0;
  end

  // Stimulus
  initial begin
    #30;  // Wait until after reset
    ivalid = 1;

    iaddress = 11'b001_0011_0000; #20;  // Miss
    iaddress = 11'b010_0011_0000; #20;  // Miss
    iaddress = 11'b010_0011_0000; #20;  // Hit
    iaddress = 11'b011_0011_0000; #20;  // Miss (should evict one)
    iaddress = 11'b001_0011_0000; #20;  // May hit or miss depending on LRU

    ivalid = 0;
    #40;

    $display("\n==== 2-Way Set-Associative Cache (LRU) ====");
    $display("Total Accesses : %0d", total_accesses);
    $display("Hits           : %0d", hit_count);
    $display("Misses         : %0d", miss_count);

    if (total_accesses > 0) begin
      automatic real hit_rate = hit_count * 1.0 / total_accesses;
      automatic real miss_rate = miss_count * 1.0 / total_accesses;
      automatic real amat = 1.0 + (miss_rate * 100.0);  // Assume miss penalty = 100 cycles
      $display("Hit Rate       : %.2f", hit_rate);
      $display("Miss Rate      : %.2f", miss_rate);
      $display("AMAT           : %.2f cycles", amat);
    end

    $stop;
  end

endmodule

