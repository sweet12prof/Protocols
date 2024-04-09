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
    logic [7:0] tx_data, rx_data, randGen;

    int ok, i; 
    logic randBit;
    logic delay_sendrxbit;

    initial begin
        ifa1.i2c_CMD        =  CMD_START_COND;
        ifa1.i_MasterByte   = 8'h0b;
        ok = randomize(randGen);
        driveOut            = '0;
        i                   = 8;
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

        @(ifa1.currCmd == I2C_IDLE);
            ifa1.i_MasterByte   = 8'heb;
            ifa1.i2c_CMD = CMD_START_COND;
        @(posedge ifa1.enNextCmd) begin 
            ifa1.i2c_CMD = CMD_READ_TRANSFER;
        end 
        @(posedge ifa1.enNextCmd) begin 
            ifa1.i2c_CMD = CMD_READ_TRANSFER;        
        end 
        @(ifa1.currCmd == I2C_MASTER_ACK) begin  
            repeat(2) begin 
                @(posedge ifa1.i_clk);
            end 
             if(ifa1.currCmd == I2C_MASTER_ACK)
                if(rx_data != randGen)
                    $display("Error in transmission");
                else 
                    $display("Simulation Suceeded");
        end 
        
        ok = randomize(randGen);
        i = 8;

        @(posedge ifa1.enNextCmd);
            ifa1.i2c_CMD = CMD_STOP_COND;
            i = 0;
 
    end

    always begin 
        //if(ifa1.simSendRxBit)
           @(posedge ifa1.simSendRxBit)
           i--;
    end 

    always  begin
        @(negedge ifa1.simAckEdge); 
       // if(ifa1.currCmd == I2C_SLAVE_ACK)
            if(tx_data != ifa1.i_MasterByte)
                $display("Error in transmission");
            else 
                $display("Simulation Suceeded");
    end 


    // always begin 
    //     @(posedge ifa1.i_clk);
    //         if(ifa1.currCmd == I2C_MASTER_ACK)
    //             if(rx_data != randGen)
    //                 $display("Error in transmission");
    //             else 
    //                 $display("Simulation Suceeded");
    // end 

    always_ff@(posedge ifa1.i_clk) begin 
        if(ifa1.simReadTxBit)
             tx_data = {tx_data[6:0] , ifa1.o_SDA};
    end 

    always_ff@(posedge ifa1.i_clk) begin 
        if(ifa1.ReadRxBit)
             rx_data = {rx_data[6:0] , ifa1.o_SDA};
    end 

    // always_ff @(posedge ifa1.i_clk ) begin 
    //     delay_sendrxbit <= ifa1.simSendRxBit;
    // end 
    

    assign ifa1.o_SDA = (ifa1.simAckEdge) ? 1'b0 : 'Z;

    assign ifa1.o_SDA = (ifa1.simSendRxBit) ? randGen[i] : 'Z;
endmodule
