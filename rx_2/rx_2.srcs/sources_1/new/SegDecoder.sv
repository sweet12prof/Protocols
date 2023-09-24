`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:44:44
// Design Name: 
// Module Name: SegDecoder
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


module SegDecoder(
    input  logic [3:0] segIN, 
    output logic [6:0] segOut
);
    always_comb begin 
    case(segIN)
        4'd0 : segOut = 7'b0000001;
        4'd1 : segOut = 7'b1001111;
        4'd2 : segOut = 7'b0010010;
        4'd3 : segOut = 7'b0000110;
        4'd4 : segOut = 7'b1001100;
        4'd5 : segOut = 7'b0100100;
        4'd6 : segOut = 7'b0100000;
        4'd7 : segOut = 7'b0001111;
        4'd8 : segOut = 7'b0000000;
        4'd9 : segOut = 7'b0000100;
       4'd10 : segOut = 7'b0001000;
       4'd11 : segOut = 7'b1100000;
       4'd12 : segOut = 7'b0110001;
       4'd13 : segOut = 7'b1000010;
       4'd14 : segOut = 7'b0110000;
       4'd15 : segOut = 7'b0111000;
     default : segOut = 7'b1000001;  
    endcase
    end 
endmodule


    // when         x"0" => controls <=  "0000001";
    //         when x"1" => controls <=  "1001111";
    //         when x"2" => controls <=  "0010010";
    //         when x"3" => controls <=  "0000110";
    //         when x"4" => controls <=  "1001100";
    //         when x"5" => controls <=  "0100100";
    //         when x"6" => controls <=  "0100000";
    //         when x"7" => controls <=  "0001111";
    //         when x"8" => controls <=  "0000000";
    //         when x"9" => controls <=  "0000100";
    //         when x"A" => controls <=  "0001000";
    //         when x"B" => controls <=  "1100000";
    //         when x"C" => controls <=  "0110001";
    //         when x"D" => controls <=  "1000010";
    //         when x"E" => controls <=  "0110000";
    //         when x"F" => controls <=  "0111000";
    //         when others => controls <="1000001";