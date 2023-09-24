`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:29:30
// Design Name: 
// Module Name: synthTop
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


module synthTop import typedefs::*;(
    input  logic clk,  rst, rxSerial, txValid,
    input  logic [7:0] txData, 
    output logic [6:0] SS_out, 
    output logic [7:0] anOut, 
    output logic       txSerial
);
    ifa myif(clk);
    logic [7:0] rxData;

    logic txValid_1, txValid_2;
    logic [7:0] txData1, txData2;

    always_ff@(posedge clk)
        begin
            txValid_1 <= txValid;
            txValid_2 <= txValid_1;
        end 

    always_ff@(posedge clk)
        begin
            txData1 <= txData;
            txData2 <= txData1; 
        end 

    assign myif.rxSerial = rxSerial;
    assign rxData = myif.rxData; 

    rxD  RD (
        .myif(myif)
    );


    SevenSegment SS(
        .clk, .rst,
        .A(4'h0), 
        .B(4'h0), 
        .C(4'h0), 
        .D(4'h0), 
        .E(4'h0), 
        .F(4'h0), 
        .G(rxData[7:4]), 
        .H(rxData[3:0]), 
        .segOut(SS_out),
        .anOut
    );

    TxD TD (
        .clk, 
        .txValid(txValid_2),
        .txData(txData2),
        .txSerial
);

    
endmodule
