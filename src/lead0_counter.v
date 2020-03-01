///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Leading zeros counter
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`include "define.v"

module lead0_counter(
    input [31:0] data_in,
    input ena,
    output [31:0] data_out
    );
    
    reg [31:0] count;

    always @(*) 
    begin
        if (ena == `ENABLED) begin
            for (count = 0; count < 32 && data_in[31 - count] != 1; count = count)
                count = count + 1;
        end
    end 

    assign data_out = count;

endmodule

