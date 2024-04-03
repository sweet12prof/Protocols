`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2024 15:33:09
// Design Name: 
// Module Name: SPI_3
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


module SPI_3 import pack_1_t::*;
#(
    parameter SPI_MODE                   = 0, 
    parameter SPI_CLOCK_PER_HALF_BIT     = 50, 
    parameter SPI_BYTE_COUNT             = 5
)
(
    input   logic         i_clk, i_rst, i_TX_DV, i_miso,
    output  logic         o_CS, 
    input   logic [7:0]   i_TX_DATA,
    output  logic [7:0]   o_RX_DATA,
    output  logic         o_SCLK,
    output  logic         o_MOSI, 
    output  logic         bytedone,
    output logic          done
);

    spi_fsm     PS, NS;
    logic       CPHA, CPOL;
    logic       sclkCurr,
                sclkNext;

    logic mosi, cs_ns, cs_ps, mosi_ns, mosi_ps;
    logic [1:0] mode;
    logic [2:0] dataCntPS, dataCntNS;
    logic [$clog2(SPI_CLOCK_PER_HALF_BIT*2 -1) : 0] clkCntPS, clkCntNS;
    logic [7:0] rx_data_ns, rx_data_ps;
    logic [$clog2(SPI_BYTE_COUNT) - 1 :0] byteCNTPS, byteCNTNS;
    logic bytedonePS, bytedoneNS;

    assign mode         = SPI_MODE;
    assign CPHA         = mode[0];
    assign CPOL         = mode[1];
    assign bytedone     = bytedonePS;
    
    always_ff @(posedge i_clk, posedge i_rst) begin : SPI_SYNC_PROC
        if(i_rst) begin 
            PS          <= SPI_IDLE;
            dataCntPS   <= '0;
            clkCntPS    <= '0;
            sclkCurr    <=  CPOL;
            cs_ps       <=  '1;
            mosi_ps     <= 'Z;
            rx_data_ps     <= 'Z;
            byteCNTPS      <= '0;
            bytedonePS     <= '0;
           
        end 
        else  begin 
            PS          <= NS;
            dataCntPS   <= dataCntNS;
            clkCntPS    <= clkCntNS;
            sclkCurr    <= sclkNext;
            cs_ps       <=  cs_ns;
            mosi_ps     <= mosi_ns;
            rx_data_ps  <= rx_data_ns;
            byteCNTPS   <= byteCNTNS;
            bytedonePS  <= bytedoneNS;
     
        end 
    end 

    always_comb begin : comnb_proc
        case(PS)
            SPI_IDLE : begin 
                sclkNext    = CPOL;
                byteCNTNS   = '0;
                bytedoneNS  = '0;
                    if(i_TX_DV)
                        begin 
                            NS              = SPI_GEN;
                            dataCntNS       = '0;
                            clkCntNS        =  clkCntPS + 1;
                            cs_ns           = '0;
                            rx_data_ns      = 'Z;
                            if(!CPHA  ) begin 
                                mosi_ns = i_TX_DATA[3'd7];
                            end
                            else begin 
                                mosi_ns = 'Z;
                            end
                        end
                    else begin 
                            NS              = SPI_IDLE;
                            dataCntNS       = '0;
                            clkCntNS        = '0;
                            cs_ns           = '1;
                            mosi_ns         = 'Z;
                            rx_data_ns      = 'Z;
                    end               
            end

            SPI_GEN : begin 
                // if(dataCntPS == 3'd7 && (clkCntPS == (SPI_CLOCK_PER_HALF_BIT*2) -2) && byteCNTPS == (SPI_BYTE_COUNT - 1) ) begin 
                //     dataCntNS     = dataCntPS;
                //     clkCntNS      = clkCntPS + 1;
                //     NS            = SPI_GEN;
                //     sclkNext      = sclkCurr;
                //     cs_ns         = ';
                //     byteCNTNS     = byteCNTPS;
                //     bytedoneNS    = '1;
                //             mosi_ns = mosi_ps; 
                //             rx_data_ns = rx_data_ps;
                                 
                // end 

                if(dataCntPS == 3'd7 && (clkCntPS == (SPI_CLOCK_PER_HALF_BIT*2) -1) && byteCNTPS == (SPI_BYTE_COUNT - 1) ) begin 
                    dataCntNS     = '0;
                    clkCntNS      = '0;
                    NS            = SPI_DONE;
                    sclkNext      = CPOL;
                    cs_ns         = '1;
                    byteCNTNS     = '0;
                    bytedoneNS    = '1;
                        if(!CPHA) begin mosi_ns = 'Z; rx_data_ns = rx_data_ps; end else begin  
                            mosi_ns = mosi_ps; 
                            rx_data_ns = {rx_data_ps[6 : 0], i_miso};
                        end                
                end 

                else if(dataCntPS == 3'd7 && (clkCntPS == (SPI_CLOCK_PER_HALF_BIT*2) -1) && byteCNTPS != (SPI_BYTE_COUNT - 1)) begin 
                    dataCntNS  = '0;
                    clkCntNS   = '0;
                    NS         = SPI_GEN;
                    sclkNext   = ~sclkCurr;
                    cs_ns      = '0;
                    byteCNTNS  = byteCNTPS + 1;
                    bytedoneNS = '1;
                    if(!CPHA) begin mosi_ns = i_TX_DATA[3'd7];  rx_data_ns = rx_data_ps; end else begin  
                            mosi_ns = mosi_ps; 
                            rx_data_ns = {rx_data_ps[6 : 0], i_miso};
                    end                
                end 

                else begin     
                    cs_ns      = '0;
                    byteCNTNS  = byteCNTPS;
                    bytedoneNS = '0;
                        if(clkCntPS == SPI_CLOCK_PER_HALF_BIT - 1) begin 
                            dataCntNS = dataCntPS;
                            clkCntNS  = clkCntPS + 1;
                            NS        = SPI_GEN;
                            sclkNext  = ~sclkCurr;
                                if(CPHA) begin
                                    mosi_ns = i_TX_DATA[3'd7 - (dataCntPS)]; 
                                    rx_data_ns = rx_data_ps;
                                end
                                else begin 
                                    mosi_ns = mosi_ps;
                                    rx_data_ns = {rx_data_ps[6 : 0], i_miso};
                                end 
                        end 
                        else if(clkCntPS == (SPI_CLOCK_PER_HALF_BIT*2) -1) begin 
                            dataCntNS = dataCntPS + 1;
                            clkCntNS  = '0;
                            NS        = SPI_GEN;
                            sclkNext  = ~sclkCurr;     
                                if(!CPHA)  begin 
                                    mosi_ns = i_TX_DATA[3'd7 - (dataCntPS + 1)]; 
                                    rx_data_ns = rx_data_ps;
                                end
                                else begin 
                                    mosi_ns     = mosi_ps;    
                                    rx_data_ns = {rx_data_ps[6 : 0], i_miso};
                                end                 
                        end 

                    else begin 
                        dataCntNS = dataCntPS;
                        clkCntNS  = clkCntPS + 1;
                        NS        = SPI_GEN;
                        sclkNext  = sclkCurr;         
                        mosi_ns   = mosi_ps;
                        rx_data_ns = rx_data_ps;
                    end
                end 
            end 

            SPI_DONE : begin
                 dataCntNS  = '0;
                 clkCntNS   = '0;
                 NS         = SPI_IDLE;
                 sclkNext   = CPOL;  
                 cs_ns      = '1;
                 mosi_ns    = 'Z;
                 rx_data_ns = 'Z;
                 byteCNTNS  = '0;
                 bytedoneNS = '0;
            end 

            default : begin 
                 dataCntNS  = '0;
                 clkCntNS   = '0;
                 NS         = SPI_IDLE;
                 sclkNext   = CPOL;  
                 cs_ns      = '1;
                 mosi_ns    = 'Z;
                 rx_data_ns = 'Z;
                 byteCNTNS  = '0;
                 bytedoneNS = '0;
            end 
        endcase
    end 
 
 always_comb begin 
    case(PS)
        SPI_IDLE : done = '0;
        SPI_GEN  : begin if(dataCntPS == 3'd7 && (clkCntPS == (SPI_CLOCK_PER_HALF_BIT*2) -2)) done = 1'b1; else done = '0; end
        SPI_DONE : done = '0;
        default  : done = 'Z;
    endcase
 end 
assign o_CS         = cs_ps;
assign o_MOSI       = mosi_ps;
assign o_SCLK       = sclkCurr;

always_ff@(posedge i_clk) begin 
    if(bytedone)
        o_RX_DATA <= rx_data_ps;
end 

endmodule
