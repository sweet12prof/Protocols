`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 11:43:42
// Design Name: 
// Module Name: mux8
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


module mux8(
    input logic [3:0] A,B,C,D, E,F,G,H,
    input logic [2:0] muxSEL,
    output logic [3:0] muxOut
);
    always_comb
    begin 
        case(muxSEL)
            0 : muxOut = A;
            1 : muxOut = B;
            2 : muxOut = C;
            3 : muxOut = D;
            4 : muxOut = E;
            5 : muxOut = F;
            6 : muxOut = G;
            7 : muxOut = H;
        endcase
    end 
endmodule
