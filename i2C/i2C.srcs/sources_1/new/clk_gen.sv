`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 01:42:07 PM
// Design Name: 
// Module Name: clk_gen
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


module clk_gen 
    #(
        parameter CLOCK_COUNT = 2,
        parameter CLOCK_PER_HALF_BIT_HALFED = 2
    )
    (
        input  logic i_clk, i_rst, i_en, 
        output logic o_clk, 
        output logic o_mid_one //for sampling at half of SCL
    );

    logic [($clog2(CLOCK_PER_HALF_BIT*2) - 1) : 0] cnt;
    logic clk_en, mid_one;
    logic clk_out;

    always_ff @(posedge i_clk, posedge i_rst)
    begin 
        if(i_rst)
            begin 
                cnt             <= 1'b0;
                clk_en          <= 1'b0;
            end 
        else begin 
            if(i_en) begin 
                if(cnt == ((CLOCK_PER_HALF_BIT * 2) - 1)) begin 
                    cnt <= '0;
                    clk_en  <= 1'b1;
                end else if (cnt == CLOCK_PER_HALF_BIT - 1) begin 
                    cnt <= cnt + 1;
                    clk_en  <= 1'b1;
                end 
                else begin
                    cnt <= cnt + 1;
                    clk_en <= 1'b0;
                end 
            end 
        end 
    end 


always_ff @( posedge i_clk ) begin : mid_one_proc
    if(cnt == CLOCK_PER_HALF_BIT_HALFED - 3 ) 
        mid_one <= 1'b1;
    else 
        mid_one <= 1'b0;
end


always_ff @(posedge i_clk, posedge i_rst) begin 
    if(i_rst)
        clk_out <= 1'b1;
    else begin 
        if(i_en) begin 
            if(clk_en) 
                clk_out <= ~clk_out; 
        end  else begin 
            clk_out <= 1'b1;
        end  
    end 
end 

assign o_mid_one = clk_out & mid_one;
assign o_clk = clk_out;

endmodule
