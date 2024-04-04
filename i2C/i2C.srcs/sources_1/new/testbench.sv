`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 02:00:18 PM
// Design Name: 
// Module Name: testbench
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


module testbench import typedefs::*;(
    ifa ifa1
);
    initial begin
        ifa1.i2c_CMD        =  CMD_START_COND;
        ifa1.i_MasterByte   = 8'hfb;
        #22;
        @(posedge ifa1.enNextCmd) begin 
            //if(ifa1.currCmd == I2C_WRITE_TRANSFER )\
                ifa1.i_MasterByte   = 8'hAB;
                ifa1.i2c_CMD         = CMD_WRITE_TRANSFER;
        end 

        @(posedge ifa1.enNextCmd) begin 
           // if(ifa1.currCmd == I2C_WRITE_TRANSFER)
                ifa1.i2c_CMD        = CMD_STOP_COND;
        end
    end 
endmodule
