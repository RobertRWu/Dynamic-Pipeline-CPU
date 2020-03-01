///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Register between EXE and MEM
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps



module pipe_exe_mem_reg(
    input clk,
    input rst,
    input wena,
    input [31:0] exe_mul_hi,
    input [31:0] exe_mul_lo,  
    input [31:0] exe_div_r,
    input [31:0] exe_div_q,  
    input [31:0] exe_clz_out,
    input [31:0] exe_alu_out, 
    input [31:0] exe_pc4,
    input [31:0] exe_rs_data_out,
    input [31:0] exe_rt_data_out,
    input [31:0] exe_cp0_out,
    input [31:0] exe_hi_out,
    input [31:0] exe_lo_out,
    input [4:0] exe_rf_waddr,
    input exe_dmem_ena,
    input exe_cutter_sign,
    input exe_rf_wena,       
    input exe_hi_wena,     
    input exe_lo_wena,
    input exe_dmem_wena,
    input [1:0] exe_dmem_w_cs,
    input [1:0] exe_dmem_r_cs,
    input exe_cutter_mux_sel,
    input [1:0] exe_hi_mux_sel,
    input [1:0] exe_lo_mux_sel,
    input [2:0] exe_cutter_sel,
    input [2:0] exe_rf_mux_sel, 
    output reg [31:0] mem_mul_hi,
    output reg [31:0] mem_mul_lo,  
    output reg [31:0] mem_div_r,
    output reg [31:0] mem_div_q,  
    output reg [31:0] mem_clz_out,
    output reg [31:0] mem_alu_out, 
    output reg [31:0] mem_pc4,
    output reg [31:0] mem_rs_data_out,
    output reg [31:0] mem_rt_data_out,
    output reg [31:0] mem_cp0_out,
    output reg [31:0] mem_hi_out,
    output reg [31:0] mem_lo_out,
    output reg [4:0] mem_rf_waddr,
    output reg mem_dmem_ena,
    output reg mem_cutter_sign,
    output reg mem_rf_wena,       
    output reg mem_hi_wena,     
    output reg mem_lo_wena,
    output reg mem_dmem_wena,
    output reg [1:0] mem_dmem_w_cs,
    output reg [1:0] mem_dmem_r_cs,
    output reg mem_cutter_mux_sel,
    output reg [1:0] mem_hi_mux_sel,
    output reg [1:0] mem_lo_mux_sel,
    output reg [2:0] mem_cutter_sel,
    output reg [2:0] mem_rf_mux_sel
    );

    always @ (posedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            mem_mul_hi <= 0;
            mem_mul_lo <= 0;
            mem_div_r <= 0;
            mem_div_q <= 0;
            mem_clz_out <= 0;
            mem_alu_out <= 0;
            mem_pc4 <= 0;
            mem_rs_data_out <= 0;
            mem_rt_data_out <= 0;
            mem_cp0_out <= 0;
            mem_hi_out <= 0;
            mem_lo_out <= 0;
            mem_rf_waddr <= 0;
            mem_dmem_ena <= 0;
            mem_cutter_sign <= 0;
            mem_rf_wena <= 0;
            mem_hi_wena <= 0;
            mem_lo_wena <= 0;
            mem_dmem_wena <= 0;
            mem_dmem_w_cs <= 0;
            mem_dmem_r_cs <= 0;
            mem_cutter_mux_sel <= 0;
            mem_hi_mux_sel <= 0;
            mem_lo_mux_sel <= 0;
            mem_cutter_sel <= 0;
            mem_rf_mux_sel <= 0;
        end

        else if(wena == `WRITE_ENABLED) begin
            mem_mul_hi <= exe_mul_hi;
            mem_mul_lo <= exe_mul_lo;
            mem_div_r <= exe_div_r;
            mem_div_q <= exe_div_q;
            mem_clz_out <= exe_clz_out;
            mem_alu_out <= exe_alu_out;
            mem_pc4 <= exe_pc4;
            mem_rs_data_out <= exe_rs_data_out;
            mem_rt_data_out <= exe_rt_data_out;
            mem_cp0_out <= exe_cp0_out;
            mem_hi_out <= exe_hi_out;
            mem_lo_out <= exe_lo_out;
            mem_rf_waddr <= exe_rf_waddr;
            mem_dmem_ena <= exe_dmem_ena;
            mem_cutter_sign <= exe_cutter_sign;
            mem_rf_wena <= exe_rf_wena;
            mem_hi_wena <= exe_hi_wena;
            mem_lo_wena <= exe_lo_wena;
            mem_dmem_wena <= exe_dmem_wena;
            mem_dmem_w_cs <= exe_dmem_w_cs;
            mem_dmem_r_cs <= exe_dmem_r_cs;
            mem_cutter_mux_sel <= exe_cutter_mux_sel;
            mem_hi_mux_sel <= exe_hi_mux_sel;
            mem_lo_mux_sel <= exe_lo_mux_sel;
            mem_cutter_sel <= exe_cutter_sel;
            mem_rf_mux_sel <= exe_rf_mux_sel;
        end
    end 

endmodule