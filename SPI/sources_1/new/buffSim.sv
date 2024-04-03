`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2024 10:12:40
// Design Name: 
// Module Name: buffSim
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


module buffSim #( 
    parameter DEPTH  = 8,
    parameter DWIDTH = 8
);;
    logic                    i_clk;
    logic                    flush, full;
    logic                    empty;
    logic [DWIDTH -1 : 0]    i_data;
    logic                    buff_WEn;
    logic                    buff_REn;
    logic [DWIDTH -1 : 0]    dataIn;
    logic [DWIDTH -1 : 0]    dataOut;
    int i;

    initial begin
        i_clk   = '0;
        flush = '1;
        #45 flush = '0; 
    end

    always begin
        #10 i_clk = ~ i_clk;
    end


    initial begin 
        #40;
        repeat(100) begin 
            i = randomize(buff_REn, buff_WEn, dataIn);
            @(posedge i_clk);
        end 
    end 


    Buffer #(8, 8) DUT(.*);

    





endmodule
