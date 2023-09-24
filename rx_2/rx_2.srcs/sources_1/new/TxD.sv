`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2023 17:29:46
// Design Name: 
// Module Name: TxD
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


module TxD import typedefs::*;(
    input  logic clk, txValid,
    input  logic [7:0] txData,
    output logic txSerial
);
    TX_mainstate PS, NS;
    int cuurBPCount, nextBPCount;
    int currDataBit, nextDataBit;
    logic currTxSerial, nextTxSerial;
    logic [7:0] txData_Reg, txData_Reg_curr;

    always_ff@(posedge clk) begin : sync_proc_main
        PS              <= NS;
        currDataBit     <= nextDataBit;
        cuurBPCount     <= nextBPCount;
        currTxSerial    <= nextTxSerial;
        txData_Reg_curr <= txData_Reg;
    end  

    always_comb begin : ns_combproc
        case(PS)
            TX_IDLE : begin
                if(!txValid) begin 
                    NS              = TX_IDLE;
                    nextDataBit     = 0;
                    nextBPCount     = 0;
                    nextTxSerial    = 1;
                    txData_Reg      = 0;
                    end  
                else begin 
                    NS              = TX_START_BIT;
                    nextDataBit     = 0;
                    nextBPCount     = 1;
                    nextTxSerial    = 0;
                    txData_Reg      = txData;
                end 
            end 

            TX_START_BIT: begin
                if(cuurBPCount != CPB) begin 
                    NS             = TX_START_BIT;
                    nextDataBit    =  0;
                    nextBPCount    = cuurBPCount + 1;
                    nextTxSerial   =  0;
                    txData_Reg     = txData_Reg_curr;
                    end 
                else begin 
                    NS             = TX_DATA_BITS;
                    nextDataBit    =  0;
                    nextBPCount    =  1;
                    nextTxSerial   = txData_Reg_curr[currDataBit];
                    txData_Reg     = txData_Reg_curr;

                end 
            end

            TX_DATA_BITS: begin 
                if ( (currDataBit + 1 == 8) && (cuurBPCount == CPB))begin 
                        NS = TX_STOP_BIT;
                        nextDataBit     = 0;
                        nextBPCount     = 1;
                        nextTxSerial    = 1;
                        txData_Reg      = txData_Reg_curr;
                    end 
                else begin
                        if(cuurBPCount == CPB) begin 
                            NS           = TX_DATA_BITS;
                            nextDataBit  = currDataBit + 1;
                            nextBPCount  = 1;
                            nextTxSerial = txData_Reg_curr[currDataBit + 1];
                            txData_Reg   = txData_Reg_curr;
                        end 
                        else begin 
                            NS           = TX_DATA_BITS;
                            nextDataBit  = currDataBit;
                            nextBPCount  = cuurBPCount + 1;
                            nextTxSerial = currTxSerial;
                            txData_Reg   = txData_Reg_curr;
                        end 
                    
                end 
            end 

            TX_STOP_BIT: begin 
                if(cuurBPCount != CPB) begin 
                        NS              = TX_STOP_BIT;
                        nextDataBit     = currDataBit;
                        nextBPCount     = cuurBPCount + 1;
                        nextTxSerial    = currTxSerial;
                        txData_Reg      = txData_Reg_curr;
                    end 
                else begin 
                    NS                  = TX_IDLE;
                    nextDataBit         = 0;
                    nextBPCount         = 0;
                    nextTxSerial        = 1;
                    txData_Reg          = 0;
                end 
            end    

            default : begin 
                NS             = TX_IDLE;
                nextDataBit    = 0;
                nextBPCount    = 0;
                nextTxSerial   = 1;
                txData_Reg     = 0; 
            end         
        endcase
    end

    assign txSerial = currTxSerial;


endmodule
