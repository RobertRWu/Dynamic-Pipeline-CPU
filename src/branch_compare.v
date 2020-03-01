///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Judge the result of beq, bne, bgez, teq
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps


module branch_compare(
    input clk,
    input rst,
    input [31:0] data_in1, 
    input [31:0] data_in2,
    input [5:0] op,
    input [5:0] func,
    input exception,
    output reg is_branch 
    );

	always @ (*) begin
	    if(rst == `RST_ENABLED)
	        is_branch <= 1'b0;
		else if(op == `BEQ_OP) 
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0;
        else if(op == `BNE_OP) 
			is_branch <= (data_in1 != data_in2) ? 1'b1 : 1'b0;
		else if(op == `BGEZ_OP) 
			is_branch <= (data_in1 >= 0) ? 1'b1 : 1'b0;	
		else if(op == `TEQ_OP && func == `TEQ_FUNC)
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0;
		else if(op == `J_OP)
			is_branch <= 1'b1;
	    else if(op == `JAL_OP)
	        is_branch <= 1'b1;
	    else if(op == `JR_OP && func == `JR_FUNC)
            is_branch <= 1'b1;
        else if(op == `JALR_OP && func == `JALR_FUNC)
            is_branch <= 1'b1;
        else if(exception)
            is_branch <= 1'b1;
        else
            is_branch <= 1'b0;
	end      


endmodule