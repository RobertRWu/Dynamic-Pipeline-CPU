///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Data forwarding
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module id_stall(
    input clk,
    input rst,
    input [5:0] op,  
    input [5:0] func,
    input [4:0] rs,
    input [4:0] rt,
    input rf_rena1,
    input rf_rena2,

    // Data from EXE  
	input [4:0] exe_rf_waddr,  
    input exe_rf_wena,
    input exe_hi_wena,
    input exe_lo_wena,

	// Data from MEM
	input [4:0] mem_rf_waddr,  
    input mem_rf_wena,
    input mem_hi_wena,
    input mem_lo_wena,

    output reg stall
    );

    reg counter;
    
    // Data hazard judge for ID and EXE and MEM
    always @ (negedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            stall <= `RUN;
            counter <= 0;
        end

        else if(counter >= 1) begin
            counter <= counter - 1;
        end

        else if(stall == `STOP) begin
            stall <= `RUN;            
        end

        else if(stall == `RUN) begin
            // MFHI
            if(op == `MFHI_OP && func == `MFHI_FUNC) begin
                // EXE HI
                if(exe_hi_wena == `WRITE_ENABLED) begin
                    counter <= 1;
                    stall <= `STOP;
                end
                // MEM HI
                else if(mem_hi_wena == `WRITE_ENABLED) begin
                    stall <= `STOP;
                end
            end

            // MFLO
            else if(op == `MFLO_OP && func == `MFLO_FUNC) begin
                // EXE LO
                if(exe_lo_wena == `WRITE_ENABLED) begin
                    counter <= 1;
                    stall <= `STOP;
                end
                // MEM LO
                else if(mem_lo_wena == `WRITE_ENABLED) begin
                    stall <= `STOP;
                end
            end

            // Rs and Rt
            else begin
                // EXE Rs
                if(exe_rf_wena == `WRITE_ENABLED && rf_rena1 == `READ_ENABLED && exe_rf_waddr == rs) begin
                    counter <= 1'b1;
                    stall <= `STOP;
                end
                // MEM Rs
                else if(mem_rf_wena == `WRITE_ENABLED && rf_rena1 == `READ_ENABLED && mem_rf_waddr == rs) begin
                    stall <= `STOP;
                end

                // EXE Rt
                if(exe_rf_wena == `WRITE_ENABLED && rf_rena2 == `READ_ENABLED && exe_rf_waddr == rt) begin
                    counter <= 1'b1;
                    stall <= `STOP;
                end
                // MEM Rt
                else if(mem_rf_wena == `WRITE_ENABLED && rf_rena2 == `READ_ENABLED && mem_rf_waddr == rt) begin
                    stall <= `STOP;
                end
            end
        end
	end      


endmodule
