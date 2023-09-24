`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 16:56:20
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
timeunit 1ns; 
timeprecision 100ps;
    logic clk;
    
    ifa myif(clk);
    ifa2 myif2(clk);
  

    initial begin 
        clk = '0; 
        forever begin
            #10 clk = ~clk;
        end
    end 

    // always begin 
    //     #10 clk = ~clk;
    // end 



    test BENCH(.myif(myif.testToDesign), .myif2(myif2.testToDesign));
    rxD DUT(.myif(myif.designToTest));
    txDifaWrap DUT2(.myif(myif2.designToTest));
endmodule
