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
    } tmode;

    //--------verification Component ------------//
    class protoVC;   
        rand bit  [6:0]     tgtAddress; 
        rand logic  [7:0]     tx_Byte_Tbl [];
        rand logic  [7:0]     rx_Byte_Tbl [];
        rand tmode           testMode;
        
        logic               sACK; 
        logic               rxBit;
        int i, j;

        virtual interface   ifa vif;
        
        logic [7:0] rxSample, txSample;
       // logic [7:0] temp;
         int cbdFmtRead, cbdFmtWrite;
         logic [7:0] temp2;
        constraint c1{
            tx_Byte_Tbl.size() inside {[1:20]};
        }

        constraint c2{
            rx_Byte_Tbl.size() inside {[1:20]};
        }
        
        function new(input virtual interface ifa aif);
            this.vif            = aif;
            this.sACK           =  1'b0;
        endfunction 

        task  startFunc(); 
            vif.i2c_CMD = CMD_START_COND;
        endtask 

        task stopFunc(); 
            vif.i2c_CMD = CMD_STOP_COND;
        endtask 

        function bit slaveFunc(); 
            return sACK;
        endfunction

        function logic [7:0] returnElement(input int i);
            return rx_Byte_Tbl[i];
        endfunction

        // function void printarrElements();
       
        //     foreach(rx_Byte_Tbl[i]) begin 
        //         temp2 = rx_Byte_Tbl[i];
        //         $display("Element i is %h", temp2);
        //         for(j=7; j >= 0; j--)
        //             $display("bits are %b", temp2[j]);

        //     end 
    //    endfunction

        task  performRead(ref logic rxBit); 
            j                   =  7;   
            @(posedge vif.enNextCmd); 
                vif.i2c_CMD = CMD_READ_TRANSFER;
          for(int i=0; i < $size(rx_Byte_Tbl); i++ )begin 
                 @(posedge vif.simSendRxBit);
                temp2 = returnElement(i);
                        for(j = 7; j>=0; j--) begin 
                            $display("j is %d", j);
                            rxBit = temp2[j];
                              @( posedge vif.simSendRxBit);
                        end
               // @(posedge vif.enNextCmd);
                //$display("j is %d", j);
            end 
            @(posedge vif.enNextCmd); stopFunc();
        endtask        
    endclass
endpackage




























        // function bit slaveAckGen();
        //     @(vif.simAckEdge) begin 
        //         return 1'b0;
        //     end 
        // endfunction 



        // task targetSenderBits(output bit rxbit); 
        //     int i=7;
        //     while (i>=0;) begin 
        //         @(posedge vif.simSendRxBit) begin 
        //             temp = rx_databyte[i];
        //             i--;
        //             rxbit = temp;
        //         end 
        //     end 
        // endtask 


        // task genRepeatedStart(output cmd startcmd);
        //     return startcmd = CMD_START_COND;
        // endtask

        // task genStop(output stopcmd);
        //     @(posedge vif.enNextCmd) begin 
        //         stopcmd = CMD_STOP_COND;
        //     end
        // endtask


        // task sampleRxBits();
        //     @(posedge vif.i_clk) begin 
        //         if(vif.ReadRxBit)
        //             rxSample = {rxSample, vif.o_SDA};
        //     end 
        // endtask

        // task sampleTxBits();
        //     @(posedge vif.i_clk) begin 
        //         if(ifa1.simReadTxBit) begin 
        //             txSample = {tx_data[6:0], vif.o_SDA};
        //         end
        //     end 
        // endtask 

        // task verifySampling();
        //     @(vif.currCmd == I2C_MASTER_ACK) begin 
        //         repeat(2) @(posedge vif.i_clk);
        //         if(vif.currCmd == I2C_MASTER_ACK) begin 
        //             if(rx_databyte == rxSample) 
        //                 $display("Controller Receive Suceeded");
        //             else 
        //                 $display("Controller Receive Failed");
        //         end 
        //     end 
        // endtask 


        // task verifyDriving();
        //     @(negedge vif.simAckEdge) begin 
        //         if(txSample == tx_databyte) begin 
        //             $display("Controller Transmit Suceeded");
        //         else    
        //             $display("Controller Transmit Failed");
        //         end 
        //     end
        // endtask
        

        // task READ_CMD();
        //     @(posedge vif.i_clk);
        //     if(vif.currCmd != I2C_IDLE)
        //         vif.i2c_CMD = CMD_STOP_COND;
        //     else 
        //         vif.i2c_CMD = CMD_START_COND; 
            
        //     @(vif.enNextCmd);
        //         vif.i2c_CMD = CMD_READ_TRANSFER;
        // endtask


        // task WRITE_CMD();
        //     @(posedge vif.i_clk);
        //         if(vif.currCmd != I2C_IDLE)
        //             vif.i2c_CMD = CMD_STOP_COND;
        //         else 
        //             vif.i2c_CMD = CMD_START_COND; 
        //     @(vif.enNextCmd);
        //         vif.i2c_CMD = CMD_WRITE_TRANSFER;
        // endtask


        // task COMBINED_CMD();
        //      @(posedge vif.i_clk) begin 
        //         if(vif.currCmd != I2C_IDLE)
        //             vif.i2c_CMD = CMD_STOP_COND;
        //         else 
        //             vif.i2c_CMD = CMD_START_COND; 
        //      end 

        //      @(vif.enNextCmd) begin 
        //         for(int j=0; j<cbdFmtWrite; j++)

        //      end 
        // endtask
   