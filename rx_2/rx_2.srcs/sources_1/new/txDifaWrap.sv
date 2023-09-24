`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 18:58:10
// Design Name: 
// Module Name: txDifaWrap
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


module txDifaWrap(
    ifa2 myif
);

    TxD TXD_WRP(
      .clk(myif.clk), 
      .txValid(myif.txValid),
      .txData(myif.txData),
      .txSerial(myif.txSerial)
    );

endmodule
