///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: MUX 
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ns

module mux_2_5(
    input [4:0] C0,
    input [4:0] C1,
    input S0,
    output reg [4:0] oZ
    );

    always @ (C0 or C1 or S0) begin
        case(S0)
            1'b0: oZ <= C0;
            1'b1: oZ <= C1;
        endcase
   end
   
endmodule