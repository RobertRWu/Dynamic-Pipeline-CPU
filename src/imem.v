///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module imem (
    input rena,
    input [10:0] addr,
    output [31:0] data_out
    );

    reg [31:0] temp [2047:0];

    assign data_out = (rena == 1) ? temp[addr] : 32'bz;
    
endmodule