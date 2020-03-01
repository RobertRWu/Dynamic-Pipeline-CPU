///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Data forwarding
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module id_df(
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
    input [31:0] exe_df_hi_out,
    input [31:0] exe_df_lo_out,
    input [31:0] exe_df_rf_wdata,
    input [5:0] exe_op,
    input [5:0] exe_func,

	// Data from MEM
	input [4:0] mem_rf_waddr,  
    input mem_rf_wena,
    input mem_hi_wena,
    input mem_lo_wena,
    input [31:0] mem_df_hi_out,
    input [31:0] mem_df_lo_out,
    input [31:0] mem_df_rf_wdata,

    output reg [31:0] rs_data_out,  
    output reg [31:0] rt_data_out,
    output reg [31:0] hi_out,     //output data of hi register
    output reg [31:0] lo_out,     //output data of lo register
    output reg stall,
    output reg if_df,
    output reg is_rs,
    output reg is_rt
    );

    
    // Data hazard judge for ID and EXE and MEM
    always @ (negedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            stall <= `RUN;
            rs_data_out <= 0;
            rt_data_out <= 0;
            hi_out <= 0;
            lo_out <= 0;
            if_df <= 0;
            is_rs <= 0;
            is_rt <= 0;
        end

        else if(stall == `STOP) begin
            stall <= `RUN;
            
            if(is_rs == 1'b1) begin
                rs_data_out <= mem_df_rf_wdata;
            end
            else begin
                rt_data_out <= mem_df_rf_wdata;
            end
        end

        else if(stall == `RUN) begin
            if_df = 0;
            is_rs = 0;
            is_rt = 0;
            // MFHI
            if(op == `MFHI_OP && func == `MFHI_FUNC) begin
                // EXE HI
                if(exe_hi_wena == `WRITE_ENABLED) begin
                    hi_out <= exe_df_hi_out;
                    if_df <= 1;
                end
                // MEM HI
                else if(mem_hi_wena == `WRITE_ENABLED) begin
                    hi_out <= mem_df_hi_out;
                    if_df <= 1;
                end
            end

            // MFLO
            else if(op == `MFLO_OP && func == `MFLO_FUNC) begin
                // EXE LO
                if(exe_lo_wena == `WRITE_ENABLED) begin
                    lo_out <= exe_df_lo_out;
                    if_df <= 1;
                end
                // MEM LO
                else if(mem_lo_wena == `WRITE_ENABLED) begin
                    lo_out <= mem_df_lo_out;
                    if_df <= 1;
                end
            end

            // Rs and Rt
            else begin
                // EXE Rs
                if(exe_rf_wena == `WRITE_ENABLED && rf_rena1 == `READ_ENABLED && exe_rf_waddr == rs) begin
                    // Lw, Lh, Lb, Lbu, Lhu
                    if(exe_op == `LW_OP || exe_op == `LH_OP || exe_op == `LHU_OP || exe_op == `LB_OP || exe_op == `LBU_OP) begin
                        stall <= `STOP;
                        is_rs <= 1;
                        if_df <= 1;
                    end
                    else begin
                        rs_data_out <= exe_df_rf_wdata;
                        if_df <= 1;
                        is_rs <= 1;
                    end
                end
                // MEM Rs
                else if(mem_rf_wena == `WRITE_ENABLED && rf_rena1 == `READ_ENABLED && mem_rf_waddr == rs) begin
                    rs_data_out <= mem_df_rf_wdata;
                    if_df <= 1;
                    is_rs <= 1;
                end

                // EXE Rt
                if(exe_rf_wena == `WRITE_ENABLED && rf_rena2 == `READ_ENABLED && exe_rf_waddr == rt) begin
                    // Lw, Lh, Lb, Lbu, Lhu
                    if(exe_op == `LW_OP || exe_op == `LH_OP || exe_op == `LHU_OP || exe_op == `LB_OP || exe_op == `LBU_OP) begin
                        stall <= `STOP;
                        is_rt <= 1;
                        if_df <= 1;
                    end
                    else begin
                        rt_data_out <= exe_df_rf_wdata;
                        if_df <= 1;
                        is_rt <= 1;
                    end
                end
                // MEM Rt
                else if(mem_rf_wena == `WRITE_ENABLED && rf_rena2 == `READ_ENABLED && mem_rf_waddr == rt) begin
                    rt_data_out <= mem_df_rf_wdata;
                    if_df <= 1;
                    is_rt <= 1;
                end
            end
        end
	end      


endmodule
