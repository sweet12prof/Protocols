`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.01.2024 09:26:04
// Design Name: 
// Module Name: pack_t
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


package pack_1_t;
    // typedef enum logic [1:0] { 
    //     IDLE, INIT, START_GEN, DONE
    // } topfsm;    

    // typedef enum logic [1:0] { 
    //     E_IDLE, START, HALF, FULL
    // } edgefsm;

    typedef enum logic[1:0] {
        SPI_IDLE, 
        SPI_GEN,
        SPI_DONE 
    } spi_fsm;

    typedef enum logic [2:0] {  
        T_SPI_IDLE,
        T_SPI_CONFIG, 
        T_SPI_COMM, 
        T_EMPT,
        T_EMPT2,
        T_SPI_READ
    } top_fsm;
endpackage
