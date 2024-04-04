`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 02:00:18 PM
// Design Name: 
// Module Name: top
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


module top import typedefs::*;;    
    
    logic i_clk, i_rst;

    ifa ifa1(i_clk, i_rst);

    testbench test(.ifa1(ifa1.exttoi2c));

    i2C DUT(
        .i_clk(ifa1.i_clk), 
        .i_rst(ifa1.i_rst),
        .o_SCL(ifa1.o_SCL), 
        .o_SDA(ifa1.o_SDA), 
        .i2c_CMD(ifa1.i2c_CMD),
        .i_MasterByte(ifa1.i_MasterByte), 
        .enNextCmd(ifa1.enNextCmd), 
        .currCmd(ifa1.currCmd)
    );

    initial begin
        i_clk = 1'b0;
        i_rst = 1'b1;
        #22;
        i_rst = 1'b0;
        forever begin
            #10 i_clk = ~ i_clk; 
        end

    end
endmodule
