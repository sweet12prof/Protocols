`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:44:44
// Design Name: 
// Module Name: ctr_2bit
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


module ctr_2bit(
    input  logic        clk, rst,
    output logic [2:0]  count
    
);
    logic[2:0] ctr = '0;

    always_ff@(posedge clk, posedge rst)
        begin : sync_proc 
            if(rst)
                ctr <= '0;
            else 
                ctr <= ctr + 1;
        end 
    
    assign count = ctr;
endmodule
