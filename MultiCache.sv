
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Computer Architecture
// Final Project: Two-Level Cache Hierarchy Simulation
// Module: Cache - Direct mapped
// Due 05/06/2025
//  
// James Jenkins, PhD student, Elec. Engr., Howard University
// Chase ...
// Instructor: Hassan Salmani, PhD.
//////////////////////////////////////////////////////////////////////////////////






//module directMapped(
//    // inputs
//    input logic clk, iRW, ivalid,
//    input [10:0] iaddress,
//    input [7:0] iRAM32 [0:31],
//    input [7:0] iwrite_data, iread_data,
//    // outputs
//    output logic L1miss, L2miss, oRW, ovalid, oready,
//    output [10:0] oaddress16 [0:15],
//    output [10:0] oaddress32 [0:31],
//    output [7:0] owrite_data, oread_data
//    );

//// instantiate wires for partitioning input address
//logic [3:0] L1offset, L1index, L2index;
//logic [4:0] L2offset;
//logic [2:0] L1tag;
//logic [1:0] L2tag;
//// assign offset, index, and tag wires their respective sections
//assign L1offset = iaddress[3:0];
//assign L1index = iaddress[7:4];
//assign L1tag = iaddress[10:8];
//assign L2offset = iaddress[4:0];
//assign L2index = iaddress[8:5];
//assign L2tag = iaddress[10:9];

//// intermediate wire for holding oread_data
//logic [7:0] reg_data;
//assign oread_data = reg_data;

//// intermediate register for holding 16 write-back addresses
//logic [10:0] wb_16 [0:15];
//assign oaddress16 = wb_16;
//// intermediate register for holding 32 write-back addresses
//logic [10:0] wb_32 [0:31];
//assign oaddress32 = wb_32;

///*
// L1 cache
// 16 blocks = index
// 16 bytes = offset
// initialize an empty array of 16 rows x 16 columns
// in one single element we load a known byte
// everything else is 0
// 11 bits = [10:8] tag, [7:4] row number, [3:0] column number
//*/
//logic [7:0] aL1cache [0:15][0:15];
//logic [2:0] aL1tag   [0:15]; // one tag per block
//logic [0:0] aL1valid [0:15]; // one valid bit per block
//logic [0:0] aL1dirty [0:15]; // one dirty bit per block
///*
// L2 cache
// 16 blocks = index
// 32 bytes = offset
// initialize an empty array of 16 rows x 32 columns
// in one single element we load a known byte
// everything else is 0
// 11 bits = [10:9] tag, [8:5] row number, [4:0] column number
//*/
//logic [7:0] aL2cache [0:15][0:31];
//logic [2:0] aL2tag   [0:15]; // one tag per block
//logic [0:0] aL2valid [0:15]; // one valid bit per block
//logic [0:0] aL2dirty [0:15]; // one dirty bit per block

//typedef enum logic[1:0] {
//        IDLE = 2'b00,
//        COMPARE_TAG = 2'b01,
//        ALLOCATE = 2'b10,
//        WRITE_BACK = 2'b11
//        // add more states for iRW implementation
//    } state_t;
//state_t state_reg, state_next;

//always_ff @(posedge clk) begin
//    if (ivalid) begin
//        state_reg <= state_next;
//    end else begin
//        state_reg <= IDLE;
//        oready <= 1;
//        ovalid <= 0;
//        L1miss <= 0;
//        L2miss <= 0;
//    end
//end

//always_comb begin
//    aL1valid[5] = 1;
//    aL1tag[5] = 3'b110;
//    aL1cache[5][5] = 8'hBE;
//    // 11001010101
//    // 110 = L1tag, 0101 = L1index, 0101 = L1offset
//    // 11 = L2tag, 0010 = L2index, 10101 = L2offset
//    aL2valid[4] = 1;
//    aL2tag[4] = 2'b11;
//    aL2cache[4][21] = 8'hAA;
//    state_next = state_reg;
//    case (state_reg)
//        IDLE : begin
//            if (ivalid) begin
//                state_next = COMPARE_TAG;
//            end
//        end
//        COMPARE_TAG : begin
//            if (aL1valid[L1index] && aL1tag[L1index] == L1tag) begin
//                reg_data = aL1cache[L1index][L1offset]; // read data in cache at the location
//                state_next = IDLE;
//            end else if (aL2valid[L2index] && aL2tag[L2index] == L2tag) begin
//                L1miss = 1; // trigger CPU halt
//                oready = 0;
//                reg_data = aL2cache[L2index][L2offset];
//                // 11011010101
//                // 110 = L1tag, 1101 = L1index, 0101 = L1offset
//                // 11 = L2tag, 0110 = L2index, 10101 = L2offset
//                if (~aL1dirty[L1index] && (L2offset & 5'b10000 == 5'b10000)) begin
//                    // promote upper 16 bytes of L2 block to L1
//                    aL1cache[L1index] = aL2cache[L2index][16:31];
//                    aL1dirty[L1index] = 1;
//                    state_next = IDLE;
//                end else if (~aL1dirty[L1index] && (L2offset & 5'b00000 == 5'b00000)) begin
//                    // promote lower 16 bytes of L2 block to L1
//                    aL1cache[L1index] = aL2cache[L2index][0:15];
//                    aL1dirty[L1index] = 1;
//                    state_next = IDLE;
//                end else begin
//                    state_next = WRITE_BACK;
//                end
//            end else if (~aL2dirty[L2index]) begin
//                L1miss = 1;
//                L2miss = 1;
//                oRW = 0; // 0 for read will be sent to memory module
//                ovalid = 1; // signal to activate memory module
//                state_next = ALLOCATE;
//            end else begin
//                L1miss = 1;
//                L2miss = 1;
//                oRW = 0; // 0 for read will be sent to memory module
//                ovalid = 1; // signal to activate memory module
//                state_next = WRITE_BACK;
//            end
//        end
//               ALLOCATE: begin
//            // Fill L2
//            for (int i = 0; i < 32; i++)
//                aL2cache[L2index][i] = iRAM32[i];
//            aL2valid[L2index] = 1;
//            aL2tag[L2index]   = L2tag;

//            // Promote half to L1
//            if (L2offset[4]) begin
//                for (int i = 0; i < 16; i++)
//                    aL1cache[L1index][i] = iRAM32[i+16];
//            end else begin
//                for (int i = 0; i < 16; i++)
//                    aL1cache[L1index][i] = iRAM32[i];
//            end
//            aL1valid[L1index] = 1;
//            aL1tag[L1index]   = L1tag;
//            aL1dirty[L1index] = 1;

//            L1miss = 0;
//            L2miss = 0;
//            ovalid = 0;
//            oready = 1;

//            state_next = IDLE;
//        end

//        WRITE_BACK: begin
//            // Stub: add logic to write dirty L1 or L2 blocks back to memory
//            state_next = ALLOCATE;
//        end
//    endcase
//end

//endmodule 




module MultiCache #(
  parameter WAY_COUNT = 1,
  parameter USE_RANDOM_REPLACEMENT = 0
)(
  input  logic clk,
  input  logic rst,
  input  logic ivalid,
  input  logic iRW,
  input  logic [10:0] iaddress,
  input  logic [7:0] iRAM32 [0:31],
  input  logic [7:0] iwrite_data,
  output logic L1miss,
  output logic ovalid,
  output logic [7:0] oread_data,
  output logic [31:0] hit_count,
  output logic [31:0] miss_count,
  output logic [31:0] total_accesses
);

  logic [3:0] offset, index;
  logic [2:0] tag;
  assign offset = iaddress[3:0];
  assign index  = iaddress[7:4];
  assign tag    = iaddress[10:8];

  logic [7:0] cache    [0:15][0:WAY_COUNT-1][0:15];
  logic [2:0] tagArray [0:15][0:WAY_COUNT-1];
  logic       valid    [0:15][0:WAY_COUNT-1];
  logic       dirty    [0:15][0:WAY_COUNT-1];
  logic [$clog2(WAY_COUNT)-1:0] lru [0:15];

  typedef enum logic [1:0] { IDLE, COMPARE_TAG, ALLOCATE } state_t;
  state_t state_reg, state_next;

  logic hit;
  logic [$clog2(WAY_COUNT)-1:0] hit_way, replace_way;

  // Internal performance registers
  logic did_access, was_hit;

  always_ff @(posedge clk) begin
    if (!ivalid)
      state_reg <= IDLE;
    else
      state_reg <= state_next;
  end

  always_comb begin
    state_next = state_reg;
    hit = 0;
    hit_way = 0;
    L1miss = 0;
    ovalid = 0;
    oread_data = 8'h00;

    case (state_reg)
      IDLE: if (ivalid) state_next = COMPARE_TAG;

      COMPARE_TAG: begin
        for (int w = 0; w < WAY_COUNT; w++) begin
          if (valid[index][w] && tagArray[index][w] == tag) begin
            hit = 1;
            hit_way = w;
          end
        end

        if (hit) begin
          oread_data = cache[index][hit_way][offset];
          lru[index] = hit_way;
          ovalid = 1;
          state_next = IDLE;
        end else begin
          L1miss = 1;
          state_next = ALLOCATE;
        end
      end

      ALLOCATE: begin
        replace_way = USE_RANDOM_REPLACEMENT ? $urandom_range(0, WAY_COUNT - 1) : lru[index];
        for (int i = 0; i < 16; i++)
          cache[index][replace_way][i] = offset[4] ? iRAM32[i+16] : iRAM32[i];

        tagArray[index][replace_way] = tag;
        valid[index][replace_way] = 1;
        dirty[index][replace_way] = 0;
        lru[index] = (replace_way + 1) % WAY_COUNT;
        state_next = COMPARE_TAG;
      end
    endcase
  end

  // Performance counters
  always_ff @(posedge clk) begin
    if (rst) begin
      total_accesses <= 0;
      hit_count <= 0;
      miss_count <= 0;
      did_access <= 0;
      was_hit <= 0;
    end else begin
      if (state_reg == COMPARE_TAG) begin
        did_access <= 1;
        was_hit <= hit;
      end else if (state_reg == IDLE && did_access) begin
        total_accesses <= total_accesses + 1;
        if (was_hit)
          hit_count <= hit_count + 1;
        else
          miss_count <= miss_count + 1;
        did_access <= 0;
      end
    end
  end

endmodule


