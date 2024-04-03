`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:44:44
// Design Name: 
// Module Name: SevenSegment
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


module SevenSegment(
    input logic clk, rst,
    input  logic [3:0] A, B, C, D, E, F, G, H, 
    output logic [6:0] segOut,
    output logic [7:0] anOut
);

    logic [2:0] muxSEL;
    logic [3:0] muxOut; 
    logic clk_500;


    SegDecoder SD(
        .segIN(muxOut), 
        .segOut
    );

    mux8 muxINST(
        .A, .B, .C, .D, .E, .F, .G, .H, .muxSEL, .muxOut
    );


    anodeDecoder ANDEC_inst(
        .anIN(muxSEL), 
        .anOut 
    );

    ctr_2bit counter(
        .clk(clk_500), 
        .rst,
        .count(muxSEL)
    );

    ClockDiv divider(
        .clk, .rst,
        .clk_500
);
endmodule
