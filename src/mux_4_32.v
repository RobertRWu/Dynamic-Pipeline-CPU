///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: MUX
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module mux_4_32(
    input [31:0] C0,
    input [31:0] C1,
    input [31:0] C2,
    input [31:0] C3,
    input [1:0] S0,
    output [31:0] oZ
    );

    reg [31:0] temp;

    always @(*) begin
        case(S0)
            2'b00: temp <= C0;
            2'b01: temp <= C1;
            2'b10: temp <= C2;
            2'b11: temp <= C3;
            default: temp <= 31'bz;
        endcase
   end
   
   assign oZ = temp;
   
endmodule