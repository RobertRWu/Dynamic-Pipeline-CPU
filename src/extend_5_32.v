///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Extend 5 bits input to 32 bits
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module extend_5_32 (
    input [4:0] a,
    output [31:0] b
    );

    assign b = {27'b0, a};
    
endmodule