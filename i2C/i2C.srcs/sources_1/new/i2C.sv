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
    parameter CLOCK_PER_HALF_BIT = ;
)
(
    output logic        o_SCL,
    inout  logic        o_SDA, 
    input  i2c_cmd_fmt  i_cmd, 
    input  logic        i_clk, 
                        i_rst, 
    input  logic        i_i2cEn
);

    states          ps, ns;
    logic           i_en;
    mode            i2cMode;


    clk_gen  CLK_GEN
    (
        .i_clk, 
        .i_rst, 
        .i_en, 
        .o_clk, 
        .o_mid_one //for sampling at half of SCL
    );








    assign i2cMode = i_cmd.mode;
    always_ff @( posedge i_clk, i_rst ) 
    begin : sync_proc
        if(i_rst)
            ps <= I2C_IDLE;
        else 
            ps <= ns;
    end

    always_comb 
    begin : ns_logic
        case(ps)
            I2C_IDLE : begin 
                if(i_i2cEn) begin 
                    ns = I2C_START_COND;
                else    
                    ns = I2C_IDLE;
                end
            end  
            
            I2C_START_COND : begin 
                 case(i2cMode) inside
                    SW, SWSR, SWMR, MW, MWSR, MWMR  : ns = I2C_WRITE_TRANSFER; 
                    SR, MR,                         : ns = I2C_READ_TRANSFER;
                endcase
            end 

            I2C_READ_TRANSFER : begin 
                ns = I2C_STOP_COND;
            end 

            I2C_WRITE_TRANSFER : begin 
                case(i2cMode)  inside 
                    SW, MW                          : ns = I2C_STOP_COND;
                    SWSR, SWMR, MWSR, MWMR          : ns = I2C_READ_TRANSFER;
                endcase
            end 

            I2C_I2C_STOP_COND : begin
                ns = I2C_IDLE;
            end 



        endcase
        
    end
endmodule
