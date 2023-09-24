

package typedefs; 

    parameter CPB = 868;
    parameter CPB_HALF = 434;
    parameter CPB_EIGHT = 6944;
          
    typedef enum logic [2:0] {
        IDLE, START_BIT, DATA_BITS, GET_RX, STOP_BIT
    } mainstate_t;

    typedef enum logic [1:0]{
        TX_IDLE, TX_START_BIT, TX_DATA_BITS, TX_STOP_BIT
    } TX_mainstate;


    class uart_rx_vc;
        rand logic  startBit; 
        rand logic [7:0] dataBit; 
        virtual interface ifa  vif;
        virtual interface ifa2 vif2;
        logic [10:0] seq;
        logic txValid;

        constraint c1{
            startBit < 1'b1;
        }

        function new(input virtual interface ifa aif, input virtual interface ifa2 aif2);
            vif  = aif; 
            vif2 = aif2;
        endfunction 

        function void post_randomize(); 
            seq = {1'b1, startBit, dataBit[0], dataBit[1], dataBit[2], dataBit[3], dataBit[4], dataBit[5], dataBit[6], dataBit[7], 1'b1};
            vif2.txData = dataBit;
        endfunction 

        task driveSeqence();
        int Ocount = 10;
           while(Ocount >= 0)
            begin
                vif.rxSerial = seq[Ocount];
                Ocount --; 
                repeat(CPB+1) begin @(vif.cb1); end
            end 
            
            // @(negedge vif.rx_Valid_o);
            //  if(vif.rxData != dataBit)
            //         begin 
            //             $display("simulation failed"); 
            //         end 
            //     else 
            //         begin 
            //             $display("Simulation passed");
            //         end 
            //     $display("Sampled Data: %d", this.dataBit);
            //     $display("Data Driven: %d", vif.rxData);
                

        endtask


        task drivetxData();
            vif2.txValid  = '1;
            vif2.txSerial = '0;
            @(vif2.cb2);
                vif2.txValid = '1;
        endtask



    endclass

endpackage