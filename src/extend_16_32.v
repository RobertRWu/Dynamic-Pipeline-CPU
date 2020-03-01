`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Extend 16 bits to signed 32 bits 
//
///////////////////////////////////////////////////////////////////////////////

module extend_16_32 (
    input [15:0] data_in,
    input sign,
    output [31:0] data_out
    );

    assign data_out = (sign == 0 || data_in[15] == 0) ? {16'b0, data_in} : {16'hffff, data_in};
    
endmodule