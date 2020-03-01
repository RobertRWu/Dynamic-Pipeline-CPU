///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Register between MEM and mem
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pipe_mem_wb_reg(
    input clk,
    input rst,
    input wena,
    input [31:0] mem_mul_hi,
    input [31:0] mem_mul_lo,  
    input [31:0] mem_div_r,
    input [31:0] mem_div_q,  
    input [31:0] mem_clz_out,
    input [31:0] mem_alu_out,
    input [31:0] mem_dmem_out, 
    input [31:0] mem_pc4,
    input [31:0] mem_rs_data_out,
    input [31:0] mem_cp0_out,
    input [31:0] mem_hi_out,
    input [31:0] mem_lo_out,
    input [4:0] mem_rf_waddr,
    input mem_rf_wena,       
    input mem_hi_wena,     
    input mem_lo_wena,
    input [1:0] mem_hi_mux_sel,
    input [1:0] mem_lo_mux_sel,
    input [2:0] mem_rf_mux_sel, 
    output reg [31:0] wb_mul_hi,
    output reg [31:0] wb_mul_lo,  
    output reg [31:0] wb_div_r,
    output reg [31:0] wb_div_q, 
    output reg [31:0] wb_clz_out, 
    output reg [31:0] wb_alu_out,
    output reg [31:0] wb_dmem_out, 
    output reg [31:0] wb_pc4,
    output reg [31:0] wb_rs_data_out,
    output reg [31:0] wb_cp0_out,
    output reg [31:0] wb_hi_out,
    output reg [31:0] wb_lo_out,
    output reg [4:0] wb_rf_waddr,
    output reg wb_rf_wena,       
    output reg wb_hi_wena,     
    output reg wb_lo_wena,
    output reg [1:0] wb_hi_mux_sel,
    output reg [1:0] wb_lo_mux_sel,
    output reg [2:0] wb_rf_mux_sel
    );

    always @ (posedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            wb_mul_hi <= 0;
            wb_mul_lo <= 0;
            wb_div_r <= 0;
            wb_div_q <= 0;
            wb_clz_out <= 0;
            wb_alu_out <= 0;
            wb_dmem_out <= 0;
            wb_pc4 <= 0;
            wb_rs_data_out <= 0;
            wb_cp0_out <= 0;
            wb_hi_out <= 0;
            wb_lo_out <= 0;
            wb_rf_waddr <= 0;
            wb_rf_wena <= 0;
            wb_hi_wena <= 0;
            wb_lo_wena <= 0;
            wb_hi_mux_sel <= 0;
            wb_lo_mux_sel <= 0;
            wb_rf_mux_sel <= 0;
        end

        else if(wena == `WRITE_ENABLED) begin
            wb_mul_hi <= mem_mul_hi;
            wb_mul_lo <= mem_mul_lo;
            wb_div_r <= mem_div_r;
            wb_div_q <= mem_div_q;
            wb_clz_out <= mem_clz_out;
            wb_alu_out <= mem_alu_out;
            wb_dmem_out <= mem_dmem_out;
            wb_pc4 <= mem_pc4;
            wb_rs_data_out <= mem_rs_data_out;
            wb_cp0_out <= mem_cp0_out;
            wb_hi_out <= mem_hi_out;
            wb_lo_out <= mem_lo_out;
            wb_rf_waddr <= mem_rf_waddr;
            wb_rf_wena <= mem_rf_wena;
            wb_hi_wena <= mem_hi_wena;
            wb_lo_wena <= mem_lo_wena;
            wb_hi_mux_sel <= mem_hi_mux_sel;
            wb_lo_mux_sel <= mem_lo_mux_sel;
            wb_rf_mux_sel <= mem_rf_mux_sel;
        end
    end 

endmodule