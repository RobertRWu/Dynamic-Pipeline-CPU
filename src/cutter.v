///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Cutter for Sb, Sh, Lb, Lh intructions
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module cutter(
    input [31:0] data_in,
    input [2:0] sel,
    input sign,
    output [31:0] data_out
    );
    
    reg [31:0] temp;
    
    always @ (*) begin
        case(sel)
            3'b001: temp <= {(sign && data_in[15]) ? 16'hffff : 16'h0000, data_in[15:0]};
            3'b010: temp <= {(sign && data_in[7]) ? 24'hffffff : 24'h000000, data_in[7:0]};
            3'b011: temp <= {24'h000000, data_in[7:0]};
            3'b100: temp <= {16'h0000, data_in[15:0]};
            default: temp <= data_in;
        endcase
    end
    
    assign data_out = temp;
    
endmodule

