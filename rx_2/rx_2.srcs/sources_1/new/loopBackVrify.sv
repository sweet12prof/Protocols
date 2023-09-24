`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 21:03:50
// Design Name: 
// Module Name: loopBackVrify
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


module loopBackVrify(
    input clk,    txValid,
    input [7:0]   txData, 
    output [7:0]  rxData
);
    logic rxSerial;

    ifa myif(clk);

    assign myif.rxSerial = rxSerial;
    assign rxData = myif.rxData;

    rxD receiver(
       .myif
    );

    TxD transmitter(
        .clk, 
        .txValid,
        .txData,
        .txSerial(rxSerial)
    );
endmodule
