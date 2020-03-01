///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module register(
    input clk, 
    input rst, 
    input wena, 
    input [31:0] data_in, 
    output [31:0] data_out 
    );

    reg [31:0] data;

    always @ (posedge clk or posedge rst)
    begin
        if(rst == 1) begin
            data <= 0;
        end

        else if(wena == 1) begin
            data <= data_in;
        end
    end
    
    assign data_out = data;

endmodule