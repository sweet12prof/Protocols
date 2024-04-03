`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.02.2024 00:02:05
// Design Name: 
// Module Name: spi_accelerometer
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


module spi_accelerometer import pack_1_t::*;
#(
    parameter READCMD          = 8'h0B, 
    parameter WRITECMD         = 8'h0A, 
    parameter SPI_BYTE_COUNT   = 5
)
(
    input   logic         i_clk, i_rst,  i_r_accel, i_miso,
    output  logic         o_SCLK,  o_CS, o_MOSI,
    output  logic [6:0]   SS_out, 
    output  logic [7:0]   anOut
);

    logic  [3:0] WbyteCountPS, WbyteCountNS,  wb1, wb2, wb3;
    logic  [7:0] tx_data_ps, tx_data_ns , xSense, ySense, zSense, o_RX_DATA, i_TX_DATA;
    logic i_TX_DV, bytedone, done, delayPS, delayNS ;
    top_fsm ps, ns;

    logic delay1, delay2, delay3;
//-------------------------------
    //logic clk, rst;
    //logic [3:0] A, B, C, D, E, F, G, H;
    assign i_TX_DATA = tx_data_ps;
    //assign i_miso    = o_MOSI;

    //------------------------
SPI_3 #(0, 50, 5) SPI_MASTER
(
    .i_clk, 
    .i_rst, 
    .i_TX_DV, 
    .i_miso,
    .o_CS, 
    .i_TX_DATA,
    .o_RX_DATA,
    .o_SCLK,
    .o_MOSI, 
    .bytedone,
    .done
);
    //-------------------------

    always_ff @(posedge i_clk, posedge i_rst) begin 
        if(i_rst) begin 
            tx_data_ps      <= '0;
            ps              <= T_SPI_IDLE; 
            WbyteCountPS    <= '0;
            delayPS         <= '0;
        end else begin 
            tx_data_ps      <= tx_data_ns;
            ps              <= ns;
            WbyteCountPS    <= WbyteCountNS;
            delayPS         <= delayNS;
        end 
    end 


    always_comb begin
        case(ps)  
            T_SPI_IDLE : begin 
                if(i_r_accel) begin 
                    WbyteCountNS    = '0;
                    ns              = T_SPI_CONFIG;
                    tx_data_ns      = READCMD;
                    delayNS         = '0;
                end 
                else begin 
                    WbyteCountNS    = '0;
                    ns              = T_SPI_IDLE;
                    tx_data_ns      = '0;
                    delayNS         = '0;
                end 
            end 

            T_SPI_CONFIG : begin
                WbyteCountNS    = '0;
                ns              = T_SPI_COMM;
                tx_data_ns      = tx_data_ps;
                delayNS         = '0;
            end

            T_SPI_COMM: begin 
                delayNS         = '0;
                if(WbyteCountPS == 1 && done) begin 
                    WbyteCountNS    = WbyteCountPS + 1;
                    ns              = T_EMPT;
                    tx_data_ns      = 'Z;
                end 
                else if(WbyteCountPS == 0 && done ) begin 
                    WbyteCountNS    = WbyteCountPS + 1;
                    ns              = T_SPI_COMM;
                    tx_data_ns      = 8'h08;
                end 
                else begin
                    WbyteCountNS    =   WbyteCountPS;
                    ns              =   T_SPI_COMM;
                    tx_data_ns      =   tx_data_ps;
                end 
            end 

            T_EMPT: begin 
                 delayNS         = '0;
                 WbyteCountNS    = WbyteCountPS;
                 ns              = T_EMPT2;
                 tx_data_ns      = 'Z;
            end 

            T_EMPT2: begin 
                 delayNS         = '0;
                 WbyteCountNS    = WbyteCountPS;
                 ns              = T_SPI_READ;
                 tx_data_ns      = 'Z;
            end 

            T_SPI_READ: begin
                if(WbyteCountPS == SPI_BYTE_COUNT - 1)
                begin 
                        tx_data_ns      =   'Z;
                        if(bytedone) begin 
                            ns              =  T_SPI_IDLE;
                            delayNS         =   1;
                            WbyteCountNS    =   '0;
                        end 
                        else begin
                            ns              = T_SPI_READ;
                            delayNS         = 0;
                            WbyteCountNS    = WbyteCountPS;
                        end     
                end else begin 
                        tx_data_ns          =   'Z;
                        ns                  = T_SPI_READ;
                        if(bytedone) begin 
                            delayNS         =   1;
                            WbyteCountNS    =   WbyteCountPS + 1;
                        end 
                        else begin
                            delayNS         = 0;
                            WbyteCountNS    = WbyteCountPS;
                        end
                end  
            end 

            default : begin 
                  WbyteCountNS    = WbyteCountPS;
                  ns              = T_SPI_IDLE;
                  tx_data_ns      = tx_data_ps;
                  delayNS         = '0;
            end 
        endcase 
    end 
    

    always_ff @(posedge i_clk) begin 
        if((delayPS == 1) && (wb1 == 2))
            xSense = o_RX_DATA;
    end 

    always_ff@ (posedge i_clk) begin
        if((delayPS == 1) && (wb1 == 3))
            ySense = o_RX_DATA;
    end 

    always_ff@(posedge i_clk) begin 
        if((delayPS == 1) && (wb1 == 4))
            zSense = o_RX_DATA;
    end 


    always_comb begin 
        case(ps) inside
            T_SPI_IDLE      : begin i_TX_DV = 0; end
            T_SPI_CONFIG    : begin i_TX_DV = 1; end 
            T_SPI_COMM      : begin i_TX_DV = 0; end 
            T_EMPT,T_EMPT2  : begin  i_TX_DV = 0; end               
            T_SPI_READ      : begin i_TX_DV = 0; end   
            default         : begin i_TX_DV = 0; end   
        endcase
    end 

    SevenSegment SS(
        .clk(i_clk), 
        .rst(i_rst),
        .A(4'h0), 
        .B(4'h0), 
        .C(xSense[7:4]), 
        .D(xSense[3:0]), 
        .E(ySense[7:4]), 
        .F(ySense[3:0]), 
        .G(zSense[7:4]), 
        .H(zSense[3:0]), 
        .segOut(SS_out),
        .anOut
    );


    always_ff @(posedge i_clk)
        begin 
            wb1 <= WbyteCountPS;
        end 
endmodule
