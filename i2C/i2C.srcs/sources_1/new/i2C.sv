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
    parameter CLOCK_PER_HALF_BIT = 10
)
(
    output logic        o_SCL,
    inout  logic        o_SDA, 
    input  logic        i2c_CMD,
    input  logic [7:0]  i_MasterByte,
    
    input  logic        i_clk, 
                        i_rst
);

    states ps, ns;
    

    logic scl_ps, scl_ns;
    logic sda_ps, sda_ns;


    logic [2:0] bitCountCurr, bitCountNext;
    logic [$clog2(CLOCK_PER_HALF_BIT)-1 : 0] cntCurr, cntNext;

    logic [7:0] readByteNS, readBytePS;
    logic readBit;
    logic ACK_BIT_NS, ACK_BIT_PS;

    assign readBit = o_SDA;

    always_ff @(posedge i_clk, posedge i_rst) begin 
        if(i_rst)  begin 
            ps              <= I2C_IDLE;
            scl_ps          <= '1;
            sda_ps          <= '1;
            cntCurr         <= '0;
            bitCountCurr    <= 3'd7;
            readBytePS      <= '0;
            ACK_BIT_PS      <= '0;
        end
        else  begin 
            ps              <= ns;   
            scl_ps          <= scl_ns;
            sda_ps          <= sda_ns;
            cntCurr         <= cntNext;
            bitCountCurr    <= bitCountNext;
            readBytePS      <= readByteNS;
            ACK_BIT_PS      <= ACK_BIT_NS;
        end 
    end 

    always_comb begin : ns_logic_sda_scl
        case(ps) 
            I2C_IDLE : begin 
                ACK_BIT_NS      = '0;
                readByteNS      = '0;
                if(i2c_CMD == CMD_START_COND) begin 
                      if(cntCurr == (CLOCK_PER_HALF_BIT/2) - 1) begin 
                        sda_ns  = '0;
                        scl_ns  = '1;
                      end 
                      else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                        sda_ns = '0;
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
                if(bitCountCurr == 3'd7) begin 
                    if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        sda_ns  = 'Z;
                        scl_ns  = ~scl_ps; 
                    end 
                    else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                        sda_ns = i_MasterByte[bitCountCurr];
                        scl_ns = ~scl_ps;
                    end
                    else begin 
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end   
                end

                else begin 
                    if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        sda_ns  =  sda_ps;
                        scl_ns  = ~scl_ps; 
                    end 
                    else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                        sda_ns = i_MasterByte[bitCountCurr];
                        scl_ns = ~scl_ps;
                    end  else begin 
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end 
                end 
            end 

            I2C_READ_TRANSFER: begin 
                ACK_BIT_NS      = '0;
                if(bitCountCurr == 3'd7) begin 
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
                    else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                            readByteNS      = readBytePS;
                            scl_ns          = ~scl_ps;
                        if(i2c_CMD == CMD_READ_TRANSFER) 
                            sda_ns  = '0;                                 //if we are to read multiple bytes, send ACK as nex SDA
                        else 
                            sda_ns  = '1;                                 // IF We art to stop readig send NACK     
                    end  
                    else begin 
                        readByteNS      = readBytePS;
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
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
                    else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                            readByteNS      = readBytePS;
                            sda_ns  = 'Z;
                            scl_ns  = ~scl_ps; 
                    end
                     else begin 
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end 
                end  
            end

            I2C_SLAVE_ACK : begin 
                 readByteNS      = readBytePS;
                 if(cntCurr == (CLOCK_PER_HALF_BIT/2) - 1) begin 
                        ACK_BIT_NS = o_SDA;
                        sda_ns     = 'Z;
                        scl_ns     = scl_ps;
                 end 
                 else if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                            ACK_BIT_NS      = ACK_BIT_PS;
                            sda_ns          = 'Z; 
                            scl_ns          = ~scl_ps;
                    end
                    else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                            ACK_BIT_NS = ACK_BIT_PS;
                            sda_ns  = 'Z;
                            scl_ns  = ~scl_ps; 
                    end
                     else begin 
                         ACK_BIT_NS = ACK_BIT_PS;
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end  
            end  

            I2C_MASTER_ACK :begin 
                readByteNS      = readBytePS;
                 ACK_BIT_NS     = '0;
                    if(cntCurr == CLOCK_PER_HALF_BIT - 1 ) begin
                            sda_ns          = sda_ps; 
                            scl_ns          = ~scl_ps;
                    end
                    else if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                            scl_ns  = ~scl_ps; 
                            if(i2c_CMD == CMD_STOP_COND)
                                sda_ns = '1;
                            else 
                                sda_ns = '0;      
                    end
                     else begin 
                        sda_ns = sda_ps;
                        scl_ns = scl_ps;
                    end 
            end 

            I2C_STOP_COND : begin 
                 readByteNS     = '0;
                 ACK_BIT_NS     = '0;
                 sda_ns         = '1;
                 scl_ns         = '1;
            end
        endcase
    end



    always_comb begin : ns_logic_for_STATES 
        case(ps)
            I2C_IDLE : begin
                bitCountNext = '0;
                if(i2c_CMD == CMD_START_COND) begin 
                    if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin 
                        ns          = I2C_WRITE_TRANSFER;
                        cntNext     = '0;
                    end 
                    else begin 
                        ns          = I2C_IDLE;
                        cntNext     = cntCurr + 1;
                    end 
                end 
            end  

            I2C_WRITE_TRANSFER : begin 
                if(bitCountNext == '0 )  begin 
                    if (cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        ns              = I2C_SLAVE_ACK;
                        cntNext         = '0;
                        bitCountNext    = '0;   
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
                        bitCountNext = bitCountCurr + 1;  
                    end  
                    else begin 
                        ns           = I2C_WRITE_TRANSFER;
                        cntNext      = cntCurr + 1;
                        bitCountNext = bitCountCurr;  
                    end 
                end
            end 

            I2C_SLAVE_ACK : begin 
                bitCountNext = '0;
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                    if(i2c_CMD == CMD_WRITE_TRANSFER) begin 
                        ns              = I2C_WRITE_TRANSFER;
                        cntNext         = '0;
                    end
                    else if (i2c_CMD == CMD_STOP_COND) begin
                        ns              = I2C_STOP_COND;
                        cntNext         = '0;
                    end 
                    else if (i2c_CMD == CMD_READ_TRANSFER) begin
                        ns              = I2C_READ_TRANSFER;
                        cntNext         = '0;
                    end
                    else begin 
                        ns              = I2C_STOP_COND;
                    end
                end else begin 
                    ns                  = I2C_SLAVE_ACK;
                    cntNext             = cntCurr + 1;
                end 
            end 


            I2C_READ_TRANSFER: begin 
                 if(bitCountNext == '0 )  begin 
                    if (cntCurr == (CLOCK_PER_HALF_BIT*2) - 1) begin
                        ns              = I2C_MASTER_ACK;
                        cntNext         = '0;
                        bitCountNext    = '0;   
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
                        bitCountNext = bitCountCurr + 1;  
                    end  
                    else begin 
                        ns           = I2C_READ_TRANSFER;
                        cntNext      = cntCurr + 1;
                        bitCountNext = bitCountCurr;  
                    end 
                end
            end 


            I2C_MASTER_ACK : begin 
                bitCountNext = '0;
                if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                    if(i2c_CMD == CMD_READ_TRANSFER) begin 
                        ns              = I2C_READ_TRANSFER;
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
                    else begin 
                        ns              = I2C_STOP_COND;
                    end
                end else begin 
                    ns                  = I2C_MASTER_ACK;
                    cntNext             = cntCurr + 1;
                end 
            end     


            I2C_STOP_COND : begin
                bitCountNext = '0;
                  if(cntCurr == (CLOCK_PER_HALF_BIT*2) - 1 ) begin 
                     ns             = I2C_IDLE;
                     cntNext        = '0;
                  end else begin 
                     ns         = I2C_STOP_COND;
                     cntNext    = cntNext + 1;
                  end 
            end 
        endcase
    end 

    // always_comb begin 
    //     case (ps)  
    //         I2C_IDLE : begin
    //             o_SDA = scl_ps;
    //         end 

    //         I2C_WRITE_TRANSFER : begin 
    //              o_SDA = scl_ps;
    //         end 

    //         I2C_SLAVE_ACK : begin
    //             o_SDA = 'Z;
    //         end 

    //         I2C_READ_TRANSFER : begin 
    //             o_SDA = 'Z;
    //         end 

    //         I2C_MASTER_ACK : begin
    //             o_SDA = scl_ps;
    //         end 

    //         I2C_STOP_COND : begin 
    //             o_SDA = scl_ps;
    //         end 

    //         default : begin
    //             o_SDA = 'Z;
    //         end
    //     endcase 
    // end 

    assign o_SDA = (ps == I2C_IDLE)             ? sda_ps : 
                   (ps == I2C_WRITE_TRANSFER)   ? sda_ps : 
                   (ps == I2C_SLAVE_ACK)        ? 'Z : 
                   (ps == I2C_READ_TRANSFER)    ? 'Z : 
                   (ps == I2C_MASTER_ACK)       ? sda_ps : 
                   (ps == I2C_STOP_COND)        ? sda_ps :
                                                  'Z; 


    assign o_SCL = scl_ps;

endmodule
