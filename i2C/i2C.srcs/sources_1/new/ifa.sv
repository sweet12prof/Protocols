`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 02:00:51 PM
// Design Name: 
// Module Name: ifa
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


interface ifa import typedefs::*; (input i_clk, i_rst);
    logic               o_SCL;
    wire                o_SDA;
    cmd                 i2c_CMD;
    logic               enNextCmd;
    states              currCmd;
    logic [7:0]         i_MasterByte;
    logic               simAckEdge      ;         // for testbench only send ack on this edge from slave
    logic               simReadTxBit    ;
    //logic               o_sampleEdge    ;

    modport i2ctoExt (
        inout   o_SDA,
        input   i_clk, 
                i_rst,
                i2c_CMD,
                i_MasterByte,
        output  enNextCmd,
                currCmd, 
                o_SCL, 
                simAckEdge,
                simReadTxBit
               // sampleEdge
    );

    modport exttoi2c(
        inout   o_SDA,
        output  i2c_CMD,
                i_MasterByte,
        input   enNextCmd,
                currCmd, 
                o_SCL, 
                i_clk, 
                i_rst, 
                simAckEdge,
                simReadTxBit 
                //sampleEdge
    );
endinterface //ifa
