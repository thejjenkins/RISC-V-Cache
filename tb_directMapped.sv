`timescale 1ns / 1ps

module tb_directMapped();

logic clk = 1'b0;
logic iRW, ivalid, L1miss, L2miss, oRW, ovalid, oready;
logic [10:0] iaddress;
logic [7:0] oread_data; // add owrite_data, iwrite_data, iread_data for CPU and mem implementation 
logic [10:0] random_addresses [0:9999];
integer L1misses = 0, L2misses = 0;

directMapped DUT(
.clk(clk),
.iRW(iRW),
.ivalid(ivalid),
//.iready(iready),
.iaddress(iaddress),
//.iwrite_data(iwrite_data),
//.iread_data(iread_data),
.L1miss(L1miss),
.L2miss(L2miss),
.oRW(oRW),
.ovalid(ovalid),
.oready(oready),
//.owrite_data(owrite_data),
.oread_data(oread_data)
);

//  Resetting the system
initial begin
    ivalid = 1'b0;
    #20
    iRW = 1'b0;
    ivalid = 1'b1;
end

//  System clock 50MHz
initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

initial begin
    forever begin 
        #10;
        if(L1miss) begin
            L1misses = L1misses + 1;
        end
        if(L2miss) begin
            L2misses = L2misses + 1;
        end
    end
end

initial begin
    for (int i = 0; i < 10000; i++) begin
        random_addresses[i] = $urandom_range(0, 2047); // 11-bit max = 2^11 - 1 = 2047
    end
end

initial begin
    #20
//    for (int i = 0; i < 10; i++) begin
//        iaddress = random_addresses[i];
//        wait(oready == 1);
//    end
    iaddress = 11'b10001010001; #20;
    iaddress = 11'b11010100010; #200;
    iaddress = 11'b11100110100; #2000;
end

////  Stop
//initial begin
//    #400 $stop;
//    // Simulation for 4ns
//end

endmodule
