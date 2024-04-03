`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:44:44
// Design Name: 
// Module Name: ClockDiv
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


module ClockDiv(
    input   logic clk, rst,
    output  logic clk_500
);
    logic [17:0] ctr;
    logic newclk;

    always_ff@(posedge clk, posedge rst)
        begin 
            if(rst) begin 
                    ctr     <= '0;
                    newclk  <= '0;
                end 
            else begin 
                if(ctr != 25000)
                    ctr <= ctr + 1;
                else begin 
                        newclk <= !newclk;
                        ctr <= '0;
                    end 
            end 
        end 

    assign clk_500 = newclk;

endmodule
