`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 01:09:59 PM
// Design Name: 
// Module Name: typedefs
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


package typedefs;
    typedef enum logic [2:0] { 
        SW, 
        SR, 
        MR,
        SWSR, 
        SWMR,
        MWSR, 
        MWMR 
    } mode;

    
    typedef struct packed {
        logic [1:0]                 transferType, 
        mode                        transferMode, 
        logic [6:0]                 w_transferBytes, 
        logic [6:0]                 r_transferBytes, 
        logic [6:0]                 targetAddress,
        logic [127:0][7:0]          wData
    } i2c_cmd_fmt;

     typedef enum logic [2:0] { 
        I2C_IDLE, 
        I2C_START_COND,
       // I2C_MASTER_ACK,
       // I2C_SLAVE_ACK, 
        I2C_READ_TRANSFER,
        I2C_WRITE_TRANSFER,
        I2C_STOP_COND
     } states;
endpackage