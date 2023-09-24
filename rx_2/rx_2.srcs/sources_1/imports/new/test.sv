module test import typedefs::*; (
    ifa myif,
    ifa2 myif2
);
    uart_rx_vc vcTest = new(myif, myif2);
    int Ocount;
    int ok;
    logic [7:0] rxData;

    default clocking cb3 @(posedge myif.clk);
        default input #1step output #5ns;
    endclocking

     assign  rxData     = myif.rxData;

    clocking cb2 @(negedge myif.rx_Valid_o);
            default input #1 output #5ns;
            input rxData;
            // input rx_Valid_o = myif.rx_Valid_o;
    endclocking

   

    initial begin
      //  Ocount = 11;

        repeat(100)
        begin 

            ok = vcTest.randomize();
            // vcTest.driveSeqence();

            // if(cb2.rxData == vcTest.dataBit)
            // begin 
            //     $display("Simulation Passed"); 
            //     $display("Data Sampled : %d", cb2.rxData); 
            //     $display("Data Driven  : %d", vcTest.dataBit); 
            // end 
            // else 
            // begin
            //      $display("Simulation Failed"); 
            //      $display("Data Sampled : %d", cb2.rxData); 
            //      $display("Data Driven  : %d", vcTest.dataBit);
            // end

            // end 
            // $finish;
            vcTest.drivetxData();
        end
    end
endmodule 
