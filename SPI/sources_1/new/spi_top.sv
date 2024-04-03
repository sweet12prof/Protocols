`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2024 08:26:29
// Design Name: 
// Module Name: spi_top
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


module spi_top #(
        parameter byte_delay_cycle_count = 0,
        parameter byte_delay  = 0
    )(
    input  logic             i_clk, 
                             i_rst, 
    output logic [7:0]       xSense, 
    output logic [7:0]       ySense, 
    output logic [7:0]       zSense
);

    logic [7:0] commandOP,  
                address;

//    assign commandOP = 8'hO

endmodule

