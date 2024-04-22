`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 01:09:59 PM
// Design Name: 
// Module Name: typedefs
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


package typedefs;
    typedef enum logic [2:0] { 
        SW, 
        SR, 
        MR,
        SWSR, 
        SWMR,
        MWSR, 
        MWMR 
    } mode;

    
    typedef struct packed {
        logic [1:0]                 transferType;
        mode                        transferMode; 
        logic [6:0]                 w_transferBytes; 
        logic [6:0]                 r_transferBytes; 
        logic [6:0]                 targetAddress;
        logic [127:0][7:0]          wData;
    } i2c_cmd_fmt;

     typedef enum logic [1:0] { 
        CMD_START_COND,
        CMD_READ_TRANSFER,
        CMD_WRITE_TRANSFER,
        CMD_STOP_COND
     } cmd;

    typedef enum logic [2:0] { 
                I2C_IDLE, 
                I2C_MASTER_ACK,
                I2C_SLAVE_ACK, 
                I2C_READ_TRANSFER,
                I2C_WRITE_TRANSFER,
                I2C_STOP_COND
    } states;


    typedef enum bit[1:0] { 
        READ, 
        WRITE, 
        COMBINED
    } mode;

    //--------verification Component ------------//
    class protoVC;

        rand bit  [7:0]     tx_databyte;
        rand bit  [7:0]     rx_databyte;

        rand mode           uvc_mode;
        rand bit            randSendBit;
        
        rand cmd            uvc_i2c_cmd;
        logic               mACK, sACK; 
        
        static int i = 7;
        virtual interface   vif;
        
        logic temp;
        logic [7:0] rxSample, txSample;
        
        function new(input virtual interface ifa aif);
            this.vif = aif;
        endfunction 

        function bit slaveAckGen();
            @(vif.simAckEdge) begin 
                return 1'b0;
            end 
        endfunction 


        task targetSenderBits(output bit rxbit); 
            while (i>=0;) begin 
                @(posedge vif.simSendRxBit) begin 
                    temp = rx_databyte[i];
                    i--;
                    rxbit = temp;
                end 
            end 
        endtask 


        task genRepeatedStart(output cmd startcmd);
            return startcmd = CMD_START_COND;
        endtask

        task genStop(output stopcmd);
            @(posedge vif.enNextCmd) begin 
                stopcmd = CMD_STOP_COND;
            end
        endtask


        task sampleRxBits();
            @(posedge vif.i_clk) begin 
                if(vif.ReadRxBit)
                    rxSample = {rxSample, vif.o_SDA};
            end 
        endtask

        task sampleTxBits();
            @(posedge vif.i_clk) begin 
                if(ifa1.simReadTxBit) begin 
                    txSample = {tx_data[6:0], vif.o_SDA};
                end
            end 
        endtask 

        task verifySampling();
            @(vif.currCmd == I2C_MASTER_ACK) begin 
                repeat(2) @(posedge vif.i_clk);
                if(vif.currCmd == I2C_MASTER_ACK) begin 
                    if(rx_databyte == rxSample) 
                        $display("Controller Receive Suceeded");
                    else 
                        $display("Controller Receive Failed");
                end 
            end 
        endtask 


        task verifyDriving();
            @(negedge vif.simAckEdge);
            if(txSample == tx_databyte) begin 
                $display("Controller Transmit Suceeded");
            else    
                $display("Controller Transmit Failed");
            end 
        endtask
        
   

       
    endclass //protocolsVC
endpackage