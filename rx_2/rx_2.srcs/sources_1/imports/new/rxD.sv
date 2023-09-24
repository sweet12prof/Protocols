`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.09.2023 14:43:26
// Design Name: 
// Module Name: rxD
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


module rxD  import typedefs::*; (
        ifa myif
    );

    mainstate_t M_PS, M_NS;

    integer mCount_curr, mCount_next;
    integer midCount_curr, midCount_next;

    logic rx_Valid, rxSerial_1, rxSerial_2;
    logic rx_shiftEnable;
    logic [7:0]sipoOut;
    logic done;
    int dataCountCurr, dataCountNext;

    assign myif.rx_shiftEnableOut = rx_shiftEnable; 

    assign myif.rx_Valid_o = done;


 //   ----syncrx----------

    always_ff @(posedge myif.clk)
        begin 
            rxSerial_1 <= myif.rxSerial;
            rxSerial_2 <= rxSerial_1;
        end 
/* ----------------------------------------------------------------
        TOP LEVEL FSM
-------------------------------------------------------------------*/
    always_ff @( posedge myif.clk ) 
    begin : sync_proc_main
        M_PS            <= M_NS;
        mCount_curr     <= mCount_next; 
        dataCountCurr   <= dataCountNext;
    end

    always_comb begin : main_ns_proc
        priority case(M_PS)
            IDLE: begin
                dataCountNext = '0;
                mCount_next <= '0; 

                if(!myif.rxSerial)
                    M_NS = START_BIT;
                else 
                    M_NS = IDLE;
            end  

            START_BIT: begin 
                dataCountNext = '0;
                if(mCount_curr != CPB_HALF)
                    begin 
                        M_NS = START_BIT;
                        mCount_next = mCount_curr + 1;
                    end 
                else 
                    begin 
                        M_NS = DATA_BITS;
                        mCount_next = 0;
                    end 
            end 

            DATA_BITS: begin 
               dataCountNext = dataCountCurr;
               if(dataCountCurr != 8)
                    begin 
                        if(mCount_curr == CPB) 
                            begin 
                                M_NS            = GET_RX;
                                mCount_next   = '0;
                            end 
                        else 
                            begin 
                                M_NS   = DATA_BITS;
                                mCount_next = mCount_curr + 1;
                            end 
                    end 
                else 
                    begin 
                        M_NS = STOP_BIT;
                        mCount_next   = '0;
                    end 

            end 

            GET_RX: begin 
                 M_NS = DATA_BITS;
                 mCount_next = mCount_curr + 1;
                 dataCountNext = dataCountCurr + 1;
            end 

            STOP_BIT: begin 
                dataCountNext = '0;
                if(mCount_curr != CPB)
                    begin 
                        M_NS = STOP_BIT;
                        mCount_next = mCount_curr + 1;
                    end 
                else 
                    begin 
                        M_NS = IDLE;
                        mCount_next = '0;
                    end 
            end 

            default: begin 
                M_NS = IDLE;
                dataCountNext = '0;
                mCount_next = '0;
            end 
        endcase 
    end

    always_comb begin : output_logic_top
        priority case(M_PS) inside
            IDLE, START_BIT, DATA_BITS : begin rx_Valid = '0; done = '0; end
            STOP_BIT                   : begin rx_Valid = '0; done = '1; end  
            GET_RX : begin rx_Valid = '1; done = '0; end 
            default : begin rx_Valid = '0; done = '0; end 
        endcase
    end 

    assign rx_shiftEnable = rx_Valid;





// /* ----------------------------------------------------------------
//         INNER LEVEL FSM
// -------------------------------------------------------------------*/

//   always_ff @(negedge myif.clk)
//         begin  :sync_proc_mid
//             MID_PS          = MID_NS;
//             midCount_curr   = midCount_next; 
//         end 

//  always_comb
//     begin  :ns_proc_MID
//         case(MID_PS)
//             IDLE2 : begin 
//                 if(!rx_Valid)
//                     begin 
//                         MID_NS          = IDLE2;
//                         midCount_next   = '0;
//                     end 
//                 else 
//                     begin 
//                         MID_NS          = COUNT_MID; 
//                         midCount_next   = '0;
//                     end 
//             end 

//             COUNT_MID : begin 
//                 if(!rx_Valid)
//                     begin
//                         MID_NS          = IDLE2;
//                         midCount_next   = '0;
//                     end 
//                 else 
//                     begin 
//                         if(midCount_curr != CPB)
//                             begin 
//                                 MID_NS        = COUNT_MID;
//                                 midCount_next = midCount_curr + 1; 
//                             end 
//                         else 
//                             begin 
//                                 MID_NS        = APPEND_RX;
//                                 midCount_next = '0;
//                             end 
//                     end  

//             end 

//             APPEND_RX : begin 
//                 if(!rx_Valid)
//                     begin
//                         MID_NS          = IDLE2;
//                         midCount_next   = '0;
//                     end 
//                 else 
//                     begin 
//                         MID_NS          = COUNT_MID;
//                         midCount_next   = '0;
//                     end 
//             end

//             default : begin 
//                 MID_NS        = IDLE2;
//                 midCount_next = '0;
//             end  
//         endcase
//     end 


//     always_comb
//     begin :  o_logic_mid_proc
//         case(MID_PS)
//             IDLE2, COUNT_MID : rx_shiftEnable = '0;
//             APPEND_RX       : rx_shiftEnable = '1;
//             default         : rx_shiftEnable = '0;
//         endcase
//     end 

    always_ff @(negedge rx_Valid)
        begin : shift_reg
                sipoOut <= {rxSerial_2, sipoOut[7:1]}; 
        end 

    always_ff @( posedge done) begin : blockName
            myif.rxData <= sipoOut;
    end
property UART_SEQ;
    @(posedge myif.clk)
        rxSerial_2 ##1 ! rxSerial_2 |=> ##(CPB_EIGHT) rxSerial_2;
endproperty
ASSERT_UART_SEQ : assert property(UART_SEQ);

endmodule





