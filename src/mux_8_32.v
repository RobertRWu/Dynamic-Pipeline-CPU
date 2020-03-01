///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module mux_8_32(
    input [31:0] C0,
    input [31:0] C1,
    input [31:0] C2,
    input [31:0] C3,
    input [31:0] C4,
    input [31:0] C5,
    input [31:0] C6,
    input [31:0] C7,
    input [2:0] S0,

    output [31:0] oZ
    );

    reg [31:0] temp;

    always @(*) begin
        case(S0)
            3'b000: temp <= C0;
            3'b001: temp <= C1;
            3'b010: temp <= C2;
            3'b011: temp <= C3;
            3'b100: temp <= C4;
            3'b101: temp <= C5;
            3'b110: temp <= C6;
            3'b111: temp <= C7;
            default: temp <= 32'bz;
        endcase
   end
   
   assign oZ = temp;
   
endmodule