`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 10:44:44
// Design Name: 
// Module Name: anodeDecoder
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


module anodeDecoder(
    input  logic [2:0] anIN, 
    output logic [7:0] anOut 
);
    always_comb
        begin : decoder_comb_proc
            case(anIN)
                0 : anOut = 'b0111_1111;
                1 : anOut = 'b1011_1111;
                2 : anOut = 'b1101_1111;
                3 : anOut = 'b1110_1111; 
                4 : anOut = 'b1111_0111;
                5 : anOut = 'b1111_1011;
                6 : anOut = 'b1111_1101;
                7 : anOut = 'b1111_1110;
                default : anOut = 'b11111_1111;
            endcase
        end 
endmodule
