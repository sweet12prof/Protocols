`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2024 06:53:29
// Design Name: 
// Module Name: sim_SPI
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




module sim_SPI;
timeunit 1ns;
timeprecision 100ps;

    logic         i_clk, i_rst, i_TX_DV, i_miso;
    logic         o_CS; 
    logic [7:0]   i_TX_DATA;
    logic [7:0]   o_RX_DATA;
    logic         o_SCLK;
    logic         o_MOSI, done; 
    logic         bytedone;
    int i;

    initial begin 
        i_clk = 0;
        i_TX_DV = 1;  
        i_rst = 1;
        #22 i_rst = 0;
         i_TX_DV = 0;
         #10 i_TX_DV = 1;
    end 

    always begin 
        #10 i_clk = ~ i_clk;
    end 

    initial begin
        repeat (128) begin 
            i = randomize(i_TX_DATA);
            @(posedge done);
        end 
    end
    SPI_3 #(3, 2, 5) DUT(.*);

    assign i_miso = o_MOSI;

    default clocking cb1 @(posedge i_clk); 
        default input #1 output #1step;
        input done, bytedone;
    endclocking

    // always begin 
     
    // end 

    initial begin
        ##5; 
        forever begin
            @cb1.done; ##2;
            if(o_RX_DATA !== $past(i_TX_DATA, 5))
                $warning("Incorrect data received");
        end
    end 
endmodule
