///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module mux_2_32(
    input [31:0] C0,
    input [31:0] C1,
    input S0,
    output reg [31:0] oZ
    );

    always @ (C0 or C1 or S0) begin
        case(S0)
            1'b0: oZ <= C0;
            1'b1: oZ <= C1;
        endcase
   end
   
endmodule