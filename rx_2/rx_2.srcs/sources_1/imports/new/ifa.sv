`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 15:55:46
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

interface ifa(input clk); 
    logic rxSerial, rx_shiftEnableOut, rx_Valid_o;
    logic [7:0] rxData;

    modport testToDesign(
        input   clk, rxData, rx_shiftEnableOut, rx_Valid_o,
        output  rxSerial
    );

    modport designToTest(
        input clk, rxSerial, 
        output rx_shiftEnableOut, rxData, rx_Valid_o
    );

    default clocking cb1 @(posedge clk); 
        default input #1step output #5ns;
        output rxSerial; 
        input  rx_shiftEnableOut,  rxData, rx_Valid_o;
    endclocking 
endinterface 



interface ifa2 (input clk); 
    logic txValid;
    logic [7:0] txData;
    logic txSerial;

    modport testToDesign(
        input  clk, txSerial, 
        output txValid, txData
    );

    modport designToTest(
        input  clk, txValid, txData, 
        output txSerial
    );


        default clocking cb2 @(posedge clk); 
            default input #1step output #5ns;
            output txData, txValid; 
            input  txSerial;
    endclocking 
endinterface
