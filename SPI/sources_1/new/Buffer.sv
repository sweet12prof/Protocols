`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.02.2024 08:59:05
// Design Name: 
// Module Name: Buffer
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


module Buffer #( 
    parameter DEPTH  = 128,
    parameter DWIDTH = 8
)(
    input  logic                    i_clk,
    input  logic                    flush, 
    output logic                    empty,full,
    //input  logic  [DWIDTH -1 : 0]   i_data,
    input  logic                    buff_WEn,
    input  logic                    buff_REn,
    input  logic [DWIDTH -1 : 0]    dataIn,
    output logic [DWIDTH -1 : 0]    dataOut
);
    logic [$clog2(DEPTH) - 1  : 0] wPointer, rPointer;
    logic [DWIDTH -1:0] MEM [0 : DEPTH-1];
    //logic [0:DEPTH - 1] DIRTY;
    
    logic empty_;
    logic full_;

    assign empty_ =  (rPointer   == wPointer) ? 1'b1 : 1'b0;
    assign full_ = (wPointer + 1 == rPointer) ? 1'b1 : 1'b0;
    
    assign empty = empty_;
    assign full = full_;
    
    //  always_ff@(posedge i_clk) begin 
    //     if(flush)
    //     begin 
    //         empty_ <= '1;
    //         full_ <= '0;
    //     end 
    //     else begin 
    //          if (rPointer + 1 == wPointer) empty_ <= 1'b1;
    //          else if (wPointer == rPointer) full_ <= 1'b1 ;
    //     end 
    //  end 

    always_ff@(posedge i_clk) begin 
        if(flush) begin 
            rPointer <= 0;
        end 
        else begin 
            if(buff_REn && !empty_) begin 
                rPointer <= rPointer + 1;
                dataOut  <= MEM[rPointer]; 
            end
        end 
    end 

    always_ff@(posedge i_clk) begin 
        if(flush) begin 
            wPointer <= 0;
        end 
        else begin 
            if(buff_WEn && !full) begin
                wPointer        <= wPointer + 1;
                MEM[wPointer]   <= dataIn;
            end
        end 
    end 
    

   
endmodule
