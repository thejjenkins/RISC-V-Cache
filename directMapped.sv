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

module directMapped(
    // inputs
    input logic clk, iRW, ivalid,
    input [10:0] iaddress,
    // input [7:0] iread_data, iwrite_data, // iread comes from mem, iwrite comes from CPU
    // outputs
    output logic L1miss, L2miss, oRW, ovalid, oready,
    output [10:0] oaddress,
    output [7:0] oread_data // add owrite_data for write functionality
    );

// instantiate wires for partitioning input address
logic [3:0] L1offset, L1index, L2index;
logic [4:0] L2offset;
logic [2:0] L1tag;
logic [1:0] L2tag;
// assign offset, index, and tag wires their respective sections
assign L1offset = iaddress[3:0];
assign L1index = iaddress[7:4];
assign L1tag = iaddress[10:8];
assign L2offset = iaddress[4:0];
assign L2index = iaddress[8:5];
assign L2tag = iaddress[10:9];

// intermediate wire for holding oread_data
logic [7:0] reg_data;
assign oread_data = reg_data;

/*
 L1 cache
 16 blocks = index
 16 bytes = offset
 initialize an empty array of 16 rows x 16 columns
 in one single element we load a known byte
 everything else is 0
 11 bits = [10:8] tag, [7:4] row number, [3:0] column number
*/
logic [7:0] aL1cache [0:15][0:15];
logic [2:0] aL1tag   [0:15]; // one tag per block
logic [0:0] aL1valid [0:15]; // one valid bit per block
logic [0:0] aL1dirty [0:15]; // one dirty bit per block

initial begin
    for (int i = 0; i < 16; i++) begin
        aL1tag[i] = 3'b000;
        aL1valid[i] = 0;
        aL1dirty[i] = 0;
        for(int j = 0; j < 16; j++) begin
            aL1cache[i][j] = 8'h00; // initialize every L1 cache location to 0
        end
    end
    // pre-load three cache entries to demonstrate what we have... 
    // the whole system does not work as expected
    // 10001010001 - this will be in L1cache
    // 11010100010 - this will be in L2cache
    // 11100110100 - this will be in RAM
    aL1tag[5]=3'b100;
    aL1valid[5]=1;
    aL1cache[5][1] = 8'hBA;
end
/*
 L2 cache
 16 blocks = index
 32 bytes = offset
 initialize an empty array of 16 rows x 32 columns
 in one single element we load a known byte
 everything else is 0
 11 bits = [10:9] tag, [8:5] row number, [4:0] column number
*/
logic [7:0] aL2cache [0:15][0:31];
logic [2:0] aL2tag   [0:15]; // one tag per block
logic [0:0] aL2valid [0:15]; // one valid bit per block
logic [0:0] aL2dirty [0:15]; // one dirty bit per block

initial begin
    for (int i = 0; i < 16; i++) begin
        aL2tag[i] = 2'b00;
        aL2valid[i] = 0;
        aL2dirty[i] = 0;
        for(int j = 0; j < 32; j++) begin
            aL2cache[i][j] = 8'h00; // initialize every L2 cache location to 0
        end
    end
    aL2tag[5] = 2'b11;
    aL2valid[5] = 1;
    aL2cache[5][2] = 8'hBE;
end

logic [9:0] delay_counter;
logic [10:0] address_reg;
assign oaddress = address_reg;

typedef enum logic[1:0] {
        IDLE = 2'b00,
        COMPARE_TAG = 2'b01,
        ALLOCATE = 2'b10,
        WRITE_BACK = 2'b11 // write-back will never be used since dirty bit will never be 1 since we
        // add more states for iRW implementation
    } state_t;
state_t state_reg, state_next;

always_ff @(posedge clk) begin
    if (ivalid) begin
        state_reg <= state_next;
        if (aL2valid[L2index] && aL2tag[L2index] == L2tag) begin
            delay_counter = delay_counter + 1;
        end
        if (state_reg == ALLOCATE) begin
            delay_counter = delay_counter + 1;
        end
    end else begin
        state_reg <= IDLE;
        oready <= 1;
        ovalid <= 0;
        L1miss <= 0;
        L2miss <= 0;
        delay_counter <= 0;
    end
end

always_comb begin
    //state_next = state_reg;
    case (state_reg)
        IDLE : begin
            delay_counter = 0;
            if (ivalid) begin
                state_next = COMPARE_TAG;
            end
        end
        COMPARE_TAG : begin
            if (aL1valid[L1index] && aL1tag[L1index] == L1tag) begin
                reg_data = aL1cache[L1index][L1offset]; // read data in cache at the location
                state_next = IDLE;
            end else if (aL2valid[L2index] && aL2tag[L2index] == L2tag) begin
                L1miss = 1; // trigger CPU halt
                oready = 0;
                // delay by 10 cycles for L2 access
                if (delay_counter < 4'd10) begin
                end else begin
                    reg_data = aL2cache[L2index][L2offset];
                end
                // 11011010101
                // 110 = L1tag, 1101 = L1index, 0101 = L1offset
                // 11 = L2tag, 0110 = L2index, 10101 = L2offset
                if (~aL1dirty[L1index] && (L2offset & 5'b10000 == 5'b10000)) begin
                    // promote upper 16 bytes of L2 block to L1
                    aL1cache[L1index] = aL2cache[L2index][16:31];
                    state_next = IDLE;
                end else if (~aL1dirty[L1index] && (L2offset & 5'b00000 == 5'b00000)) begin
                    // promote lower 16 bytes of L2 block to L1
                    aL1cache[L1index] = aL2cache[L2index][0:15];
                    state_next = IDLE;
                end else begin
                    state_next = WRITE_BACK;
                end
            end else if (~aL2dirty[L2index]) begin
                L1miss = 1;
                L2miss = 1;
                oready = 0;
                oRW = 0; // 0 for read will be sent to memory module
                ovalid = 1; // signal to activate memory module
                address_reg = iaddress; // simulate passing desired address to RAM
                state_next = ALLOCATE;
            end else begin
                L1miss = 1;
                L2miss = 1;
                oRW = 0; // 0 for read will be sent to memory module
                ovalid = 1; // signal to activate memory module
                state_next = WRITE_BACK;
            end
        end 
        ALLOCATE : begin
            // copy 32 bytes from main memory into L2 cache
            // copy 16 of those 32 bytes into L1 cache
            // state_next = COMPARE_TAG;
            if (delay_counter < 7'd100) begin
            end else begin
                aL2tag[L2index] = L2tag;
                aL2valid[L2index] = 1;
                for(int i = 0; i < 32; i++) begin
                    aL2cache[L2index][i] = $urandom_range(0, 256);
                end
                if (~aL1dirty[L1index] && (L2offset & 5'b10000 == 5'b10000)) begin
                    // promote upper 16 bytes of L2 block to L1
                    aL1valid[L1index] = 1;
                    aL1tag[L1index] = L1tag;
                    aL1cache[L1index] = aL2cache[L2index][16:31];
                end else if (~aL1dirty[L1index] && (L2offset & 5'b00000 == 5'b00000)) begin
                    // promote lower 16 bytes of L2 block to L1
                    aL1valid[L1index] = 1;
                    aL1tag[L1index] = L1tag;
                    aL1cache[L1index] = aL2cache[L2index][0:15];
                end else begin
                    state_next = WRITE_BACK;
                end
            end
            L1miss = 0;
            L2miss = 0;
            state_next = COMPARE_TAG;
        end
        WRITE_BACK : begin
            // if(L1miss && ~L2miss) copy 16 bytes from L1 to main memory
            // else if(L1miss && L2miss) copy 32 bytes from L2 to main memory
            // state_next = ALLOCATE;
            // UNUSED 
            state_next = ALLOCATE;
        end
    endcase
end

endmodule
