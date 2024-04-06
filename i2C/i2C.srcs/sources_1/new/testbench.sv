`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 02:00:18 PM
// Design Name: 
// Module Name: testbench
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


module testbench import typedefs::*;(
    ifa ifa1
);
    logic driveOut;
    logic [7:0] tx_data;

    initial begin
        ifa1.i2c_CMD        =  CMD_START_COND;
        ifa1.i_MasterByte   = 8'h0b;
        driveOut            = '0;
        #22;
        @(posedge ifa1.enNextCmd) begin 
                ifa1.i_MasterByte   = 8'h0B;
                ifa1.i2c_CMD         = CMD_WRITE_TRANSFER;
        end 

        @(posedge ifa1.enNextCmd) begin 
           // if(ifa1.currCmd == I2C_WRITE_TRANSFER)
                ifa1.i_MasterByte   = 8'h0B;
                ifa1.i2c_CMD        = CMD_WRITE_TRANSFER;
        end

        @(posedge ifa1.enNextCmd) begin
            ifa1.i2c_CMD    = CMD_STOP_COND;
        end 
    end


    always  begin
        @(negedge ifa1.simAckEdge); 
            if(tx_data != ifa1.i_MasterByte)
                $display("Error in transmission");
            else 
                $display("Simulation Suceeded");
    end 


    always_ff@(posedge ifa1.i_clk) begin 
        if(ifa1.simReadTxBit)
             tx_data = {tx_data[6:0] , ifa1.o_SDA};
    end 

    assign ifa1.o_SDA = (ifa1.simAckEdge) ? 1'b0 : 'Z;
endmodule
