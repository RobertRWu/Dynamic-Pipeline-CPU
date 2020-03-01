///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Register between Instruction Fetch Module and Instruction Decoder Module
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module pipe_if_id_reg(
    input clk,
    input rst,
    input [31:0] if_pc4,
    input [31:0] if_instruction,
    input stall,
    input is_branch,
    output reg [31:0] id_pc4,
    output reg [31:0] id_instruction 
    );

    always @ (posedge clk or posedge rst)
    begin
		if (rst == `RST_ENABLED) begin
		    id_pc4 <= `ZERO_32BIT;
		    id_instruction <= `ZERO_32BIT;       
		end

        else if(is_branch == 1'b1) begin
            id_pc4 <= 32'h0;
            id_instruction <= 32'h0;
        end

        else if(stall == `RUN) begin
		    id_pc4 <= if_pc4;
		    id_instruction <= if_instruction;
		end
	end

endmodule