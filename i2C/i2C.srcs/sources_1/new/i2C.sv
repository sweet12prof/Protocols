`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 01:09:59 PM
// Design Name: 
// Module Name: i2C
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


module i2C import typedefs::*;
#(
    parameter CLOCK_PER_HALF_BIT = 2
)
(
    output logic        simAckEdge,
    output logic        simReadTxBit,
    output logic        simRead,

    output logic        simSendRxBit, 
    output logic        ReadRxBit,
    
    output logic        o_SCL,
    output logic        enNextCmd,
    output states       currCmd,
    
    inout  logic        o_SDA, 
    input  cmd          i2c_CMD,
    input  logic [7:0]  i_MasterByte,
    input  logic        i_clk, 
                        i_rst
);

    states ps, ns;
    

    logic scl_ps, scl_ns;
    logic sda_ps, sda_ns;
    logic nCmdps, nCmdns; 
    logic simSendRxBitPS, simSendRxBitNS;

    logic preAck, ackBit;



    logic [3:0] bitCountCurr, bitCountNext;
    logic [$clog2(CLOCK_PER_HALF_BIT*2)-1 : 0] cntCurr, cntNext;

    logic [7:0] readByteNS, readBytePS;
    logic readBit;
    logic ACK_BIT_NS, ACK_BIT_PS,  simAckEdgePS, simAckEdgeNS;

    assign readBit    = o_SDA;
    assign currCmd    = ps;
    assign enNextCmd  = nCmdps;
    
   // assign ZImp       = 'Z;

always_ff @(posedge i_clk, posedge i_rst) begin 
    if(i_rst)  begin 
            ps              <= I2C_IDLE;
            scl_ps          <= '1;
            sda_ps          <= '1;
            cntCurr         <= '0;
            bitCountCurr    <= 4'd8;
            readBytePS      <= '0;
            ACK_BIT_PS      <= '0;
            nCmdps          <= '0;
            simAckEdgePS    <= '0;
            simSendRxBitPS  <= '0;
    end
    else  begin 
            ps              <= ns;   
            scl_ps          <= scl_ns;
            sda_ps          <= sda_ns;
            cntCurr         <= cntNext;
            bitCountCurr    <= bitCountNext;
            readBytePS      <= readByteNS;
            ACK_BIT_PS      <= ACK_BIT_NS;
            nCmdps          <= nCmdns;
            simAckEdgePS    <= simAckEdgeNS;
            simSendRxBitPS  <= simSendRxBitNS;
    end 
end 

always_comb begin : ns_logic_sda_scl
    case(ps) 
        I2C_IDLE : begin 
            ACK_BIT_NS      = '0;
            readByteNS      = '0;
            simAckEdgeNS    = '0;
            simSendRxBitNS  = '0;
            if(i2c_CMD == CMD_START_COND) begin 
                    if(cntCurr == (CLOCK_PER_HALF_BIT) - 1) begin 
                        sda_ns  = '0;
                        scl_ns  = scl_ps;
                    end 
                    else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                        sda_ns = i_MasterByte[bitCountCurr-1]; 
                        scl_ns = ~scl_ps;
                    end 
                    else begin 
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end 
            end else begin 
                scl_ns          =  '1;
                sda_ns          =  '1;
            end
        end 

        I2C_WRITE_TRANSFER: begin 
            readByteNS      = '0;
            ACK_BIT_NS      = '0;
            simAckEdgeNS    = '0;
            simSendRxBitNS  = '0;
            if(bitCountCurr == 4'd0) begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                    sda_ns  = 'Z;
                    scl_ns  = ~scl_ps; 
                    simAckEdgeNS    = '1;
                end 
                else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                    sda_ns = sda_ps;
                    scl_ns = ~scl_ps;
                end
                else begin 
                    sda_ns = sda_ps;
                    scl_ns = scl_ps;
                end   
            end
            else begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                    sda_ns = i_MasterByte[bitCountCurr-1];
                    scl_ns  = ~scl_ps; 
                end 
                else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                    sda_ns = sda_ps;
                    scl_ns = ~scl_ps;
                end  else begin 
                    sda_ns = sda_ps;
                    scl_ns = scl_ps;
                end 
            end 
        end 

        I2C_READ_TRANSFER: begin 
            ACK_BIT_NS      = '0;
            simAckEdgeNS    = '0;
            simSendRxBitNS  = '1;
            if(bitCountCurr == 4'd0) begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT/2) - 1) begin 
                    readByteNS[7:0]     = {readBytePS[6:0],  o_SDA};
                    sda_ns              = 'Z;
                    scl_ns              = scl_ps;
                    simAckEdgeNS        = '0;
                end 
                else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                        readByteNS      = readBytePS;
                        sda_ns          = 'Z; 
                        scl_ns          = ~scl_ps;
                end
                else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 2) begin
                        readByteNS      = readBytePS;
                        scl_ns          = scl_ps;
                        simSendRxBitNS  = '0; 
                        sda_ns          = 'Z;                                 
                end  
                else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        readByteNS      = readBytePS;
                        scl_ns          = ~scl_ps;
                    if(i2c_CMD == CMD_READ_TRANSFER) 
                        sda_ns          = '0;                                 //if we are to read multiple bytes, send ACK as next SDA
                    else 
                        sda_ns          = '1;                                 // IF We are to stop readig send NACK NB: could be repeated start     
                end  
                else begin 
                    readByteNS      = readBytePS;
                    sda_ns              = sda_ps;
                    scl_ns              = scl_ps;
                end 
            end 
            else begin  
                if(cntCurr == (CLOCK_PER_HALF_BIT/2) - 1) begin 
                    readByteNS[7:0] = {readBytePS[6:0],  o_SDA};
                    sda_ns  = 'Z;
                    scl_ns  = scl_ps;
                end 
                else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                        readByteNS      = readBytePS;
                        sda_ns          = 'Z; 
                        scl_ns          = ~scl_ps;
                end
                else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 2) begin
                        readByteNS      = readBytePS;
                        sda_ns          = 'Z;
                        scl_ns          =  scl_ps; 
                        simSendRxBitNS  = 'b0;
                end
                else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        readByteNS      = readBytePS;
                        sda_ns          = 'Z;
                        scl_ns          = ~scl_ps; 
                end
                    else begin 
                    sda_ns = sda_ps;
                    scl_ns = scl_ps;
                end 
            end  
        end

        I2C_SLAVE_ACK : begin 
            readByteNS      = readBytePS;
            simAckEdgeNS    = '1;
            simSendRxBitNS  = '0;
            if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                    ACK_BIT_NS      = ACK_BIT_PS;
                    scl_ns          = ~scl_ps;
                    sda_ns          = sda_ps; 
            end
            else if(cntCurr == (CLOCK_PER_HALF_BIT/2) - 1) begin 
                ACK_BIT_NS = o_SDA;
                sda_ns     = 'Z;
                scl_ns     = scl_ps;
            end 

            else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                    ACK_BIT_NS      = ACK_BIT_PS;
                    simAckEdgeNS    = '0;

                    //-----------------------------------------
                    if(i2c_CMD == CMD_READ_TRANSFER) 
                        simSendRxBitNS = '1;
                    else 
                        simSendRxBitNS = '0;
                    //-----------------------------------------

                    if(i2c_CMD == CMD_STOP_COND) begin 
                        scl_ns = '1;
                    end
                    else if(i2c_CMD == CMD_START_COND) begin 
                        scl_ns = '1;
                    end 
                    else  begin 
                        scl_ns  = ~scl_ps; 
                    end
                    
                    if(i2c_CMD == CMD_WRITE_TRANSFER)                //commented code applies to ....-1 condition
                        sda_ns = i_MasterByte[bitCountCurr-1];        // we are going to start writing next byte
                    else if(i2c_CMD == CMD_STOP_COND)
                        sda_ns = 1'b1;
                    else if(i2c_CMD == CMD_START_COND)
                        sda_ns = 1'b1; 
                    else 
                        sda_ns = 'Z;                               //this should be 2 conditions, when we are doing a combined format(ie; reverse operation)
            end                                                    // and if we are going to send stop byte next
            else begin 
                    ACK_BIT_NS = ACK_BIT_PS;
                sda_ns = sda_ps;
                scl_ns = scl_ps;
            end  
        end  

        I2C_MASTER_ACK :begin 
            readByteNS       = readBytePS;
            simAckEdgeNS    = '0;
            simSendRxBitNS  = '0;
                ACK_BIT_NS     = '0;
                if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                        sda_ns          = sda_ps; 
                        scl_ns          = ~scl_ps;
                end
                else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        if(i2c_CMD == CMD_START_COND) begin 
                            scl_ns = 1'b1;    
                            sda_ns = 1'b1;               //repeated start
                        end 
                        else if(i2c_CMD == CMD_STOP_COND) begin 
                            scl_ns = 1'b1; 
                            sda_ns = '1;                  //if next command is stop
                        end 
                        else if(i2c_CMD == CMD_READ_TRANSFER) begin 
                            scl_ns           = ~scl_ps;
                            sda_ns           = 'Z;
                            simSendRxBitNS   = '1;
                        end 
                        else  begin 
                            scl_ns  = ~scl_ps; 
                            sda_ns = '0;
                        end 
                        simAckEdgeNS    = '0;
                end
                else begin 
                    sda_ns = sda_ps;
                    scl_ns = scl_ps;
                end 
        end 

        I2C_STOP_COND : begin 
                simAckEdgeNS        = '0;
                readByteNS          = '0;
                ACK_BIT_NS          = '0;
                sda_ns              = '1;
                scl_ns              = '1;
                simSendRxBitNS      = '0;
        end
    endcase
end

//----------------------------------------------------------NS-----------------------------------------------------------------//

always_comb begin : ns_logic_for_STATES 
    case(ps)
        I2C_IDLE : begin
            bitCountNext = 4'd8;
            nCmdns       = '0;
            if(i2c_CMD == CMD_START_COND) begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                    ns          = I2C_WRITE_TRANSFER;
                    bitCountNext = bitCountCurr - 1;
                    cntNext     = '0;
                end 
                else begin 
                    ns          = I2C_IDLE;
                    cntNext     = cntCurr + 1;
                end 
            end 
        end  

        I2C_WRITE_TRANSFER : begin 
            nCmdns =  '0;
            if(bitCountCurr == '0 )  begin 
                if (cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                    ns              = I2C_SLAVE_ACK;
                    cntNext         = '0;
                    bitCountNext    = 4'd8;   
                end
                else if(cntCurr == (CLOCK_PER_HALF_BIT) - 1 ) begin 
                    ns              = I2C_WRITE_TRANSFER;
                    cntNext         = cntCurr + 1;
                    nCmdns          = '1;
                    bitCountNext    = bitCountCurr;
                end 
                else begin 
                        ns              = I2C_WRITE_TRANSFER;
                        cntNext         = cntCurr + 1;
                        bitCountNext    = bitCountCurr;   
                end  
            end 
            else begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                    ns           = I2C_WRITE_TRANSFER;
                    cntNext      = '0;
                    bitCountNext = bitCountCurr - 1;  
                end  
                else begin 
                    ns           = I2C_WRITE_TRANSFER;
                    cntNext      = cntCurr + 1;
                    bitCountNext = bitCountCurr;  
                end 
            end
        end 

        I2C_SLAVE_ACK : begin 
            bitCountNext = 4'd8;
            nCmdns       = '0;
            if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                if(i2c_CMD == CMD_WRITE_TRANSFER) begin 
                    ns              = I2C_WRITE_TRANSFER;
                    bitCountNext   = bitCountCurr - 1;
                    cntNext         = cntCurr + 1;                         
                end
                else if (i2c_CMD == CMD_STOP_COND) begin
                    ns              = I2C_STOP_COND;
                    cntNext         = '0;
                end 
                else if (i2c_CMD == CMD_READ_TRANSFER) begin
                    ns              = I2C_READ_TRANSFER;
                    bitCountNext    = bitCountCurr - 1;
                    cntNext         = '0;                           // this is basically when we do a reverse operation, however expect a 1 cycle overhead from earlier process
                end                                                 // so cnt next should be incremented here, when the code is updated later
                else if (i2c_CMD == CMD_START_COND) begin 
                    ns              = I2C_IDLE; 
                    bitCountNext    = bitCountCurr -1 ;
                    cntNext         = '0; 
                end 
                else begin 
                    ns              = I2C_STOP_COND;
                    cntNext         = '0;
                end
            end 
            else if(cntCurr == (CLOCK_PER_HALF_BIT) - 1 ) begin 
                    ns              = I2C_SLAVE_ACK;
                    cntNext         = cntCurr + 1;
                    // nCmdns          = 1'b0;
            end 
            else begin 
                ns                  = I2C_SLAVE_ACK;
                cntNext             = cntCurr + 1;
            end 
        end 


        I2C_READ_TRANSFER: begin 
            nCmdns = '0;
                if(bitCountCurr == '0 )  begin 
                    if (cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        ns              = I2C_MASTER_ACK;
                        cntNext         = '0;
                        bitCountNext    = 4'd8;   
                        nCmdns          = '0;
                    end
                    else if(cntCurr == (CLOCK_PER_HALF_BIT) - 1 ) begin 
                        ns              = I2C_READ_TRANSFER;
                        cntNext         = cntCurr + 1;
                        bitCountNext    = bitCountCurr;
                        nCmdns          = '1;
                    end 
                    else begin 
                            ns              = I2C_READ_TRANSFER;
                            cntNext         = cntCurr + 1;
                            bitCountNext    = bitCountCurr;   
                    end  
                end
            else begin 
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                    ns           = I2C_READ_TRANSFER;
                    cntNext      = '0;
                    bitCountNext = bitCountCurr - 1;  
                end  
        
                else begin 
                    ns           = I2C_READ_TRANSFER;
                    cntNext      = cntCurr + 1;
                    bitCountNext = bitCountCurr;  
                end 
            end
        end 


        I2C_MASTER_ACK : begin 
            nCmdns       = '0;
            bitCountNext = 4'd8;
            if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                if(i2c_CMD == CMD_READ_TRANSFER) begin 
                    ns              = I2C_READ_TRANSFER;
                    bitCountNext   = bitCountCurr - 1;
                    cntNext         = '0;
                end
                else if (i2c_CMD == CMD_STOP_COND) begin
                    ns              = I2C_STOP_COND;
                    cntNext         = '0;
                end 
                else if (i2c_CMD == CMD_WRITE_TRANSFER) begin
                    ns              = I2C_WRITE_TRANSFER;
                    cntNext         = '0;
                end
                else if (i2c_CMD == CMD_START_COND) begin 
                    ns              = I2C_IDLE; 
                    bitCountNext    = bitCountCurr - 1;
                    cntNext         = '0;
                end 
                else begin 
                    ns              = I2C_STOP_COND;
                    cntNext         = '0;
                end
            end 
            
            else if(cntCurr == (CLOCK_PER_HALF_BIT) - 1 ) begin 
                    ns              = I2C_MASTER_ACK;
                    cntNext         = cntCurr + 1;
            end 

            else begin 
                ns                  = I2C_MASTER_ACK;
                cntNext             = cntCurr + 1;
            end 
        end     


        I2C_STOP_COND : begin
            nCmdns       = '0;
            bitCountNext = '0;
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                    nCmdns         = '1;
                    ns             = I2C_IDLE;
                    cntNext        = '0;
                end else begin 
                    ns         = I2C_STOP_COND;
                    cntNext    = cntNext + 1;
                end 
        end 
    endcase
end 
    
assign o_SDA =  (ps == I2C_IDLE)             ? sda_ps : 
                (ps == I2C_WRITE_TRANSFER)   ? sda_ps : 
                (ps == I2C_SLAVE_ACK)        ? sda_ps : 
                (ps == I2C_READ_TRANSFER)    ? sda_ps : 
                (ps == I2C_MASTER_ACK)       ? sda_ps : 
                (ps == I2C_STOP_COND)        ? sda_ps :
                                               'Z; 

assign o_SCL = scl_ps;

always_ff @(posedge i_clk) begin 
    if(ps == I2C_SLAVE_ACK) begin 
        preAck <= scl_ps & scl_ns;
    end 
end 


assign simAckEdge = simAckEdgePS;

always_ff @(posedge i_clk) begin 
    if(ps == I2C_WRITE_TRANSFER)
        simReadTxBit   <=  scl_ps & scl_ns;
end


always_ff @(posedge i_clk) begin 
    if(ps == I2C_READ_TRANSFER) begin 
        ReadRxBit <= scl_ps & scl_ns;
    end 
end 

assign simSendRxBit = simSendRxBitPS;

assign ackBit       = preAck & o_SDA;

always_comb 
begin : o_logic_For_SimRead
    case(ps)
        I2C_READ_TRANSFER: simRead = '1;
        default          : simRead = '0;
    endcase
end 

endmodule
