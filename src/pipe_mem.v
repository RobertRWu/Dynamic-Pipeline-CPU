///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Memory
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pipe_mem(
    input clk,
    input [31:0] mul_hi,
    input [31:0] mul_lo,  
    input [31:0] div_r,
    input [31:0] div_q,  
    input [31:0] clz_out,
    input [31:0] alu_out, 
    input [31:0] pc4,
    input [31:0] rs_data_out,
    input [31:0] rt_data_out,
    input [31:0] cp0_out,
    input [31:0] hi_out,
    input [31:0] lo_out, 
    input [4:0] rf_waddr,
    input dmem_ena,
    input rf_wena,       
    input hi_wena,     
    input lo_wena,    
    input dmem_wena,
    input cutter_sign,
    input [1:0] dmem_w_cs,
    input [1:0] dmem_r_cs,
    input cutter_mux_sel,
    input [2:0] cutter_sel,
    input [1:0] hi_mux_sel,
    input [1:0] lo_mux_sel,
    input [2:0] rf_mux_sel, 
    output [31:0] mem_mul_hi,  // Higher bits of the multiplication result
    output [31:0] mem_mul_lo,  // Lower bits of the multiplication result
    output [31:0] mem_div_r,  // Remainder of the division result
    output [31:0] mem_div_q,  // Quotient of the division result
    output [31:0] mem_clz_out,
    output [31:0] mem_alu_out,  // Result of ALU
    output [31:0] mem_dmem_out,
    output [31:0] mem_pc4,
    output [31:0] mem_rs_data_out,
    output [31:0] mem_cp0_out,
    output [31:0] mem_hi_out,
    output [31:0] mem_lo_out,
    output [4:0] mem_rf_waddr,
    output mem_rf_wena,       
    output mem_hi_wena,     
    output mem_lo_wena,    
    output [1:0] mem_hi_mux_sel,
    output [1:0] mem_lo_mux_sel,
    output [2:0] mem_rf_mux_sel
    );

    wire [31:0] dmem_out;
    wire [31:0] cutter_mux_out;

    assign mem_pc4 = pc4;
    assign mem_rs_data_out = rs_data_out;
    assign mem_hi_out = hi_out;
    assign mem_lo_out = lo_out;
    assign mem_cp0_out = cp0_out;
    assign mem_mul_hi = mul_hi;
    assign mem_mul_lo = mul_lo;
    assign mem_div_q = div_q;
    assign mem_div_r = div_r;
    assign mem_clz_out = clz_out;
    assign mem_alu_out = alu_out;
    assign mem_rf_waddr = rf_waddr;
    assign mem_rf_wena = rf_wena;
    assign mem_hi_wena = hi_wena;
    assign mem_lo_wena = lo_wena;
    assign mem_hi_mux_sel = hi_mux_sel;
    assign mem_lo_mux_sel = lo_mux_sel;
    assign mem_rf_mux_sel = rf_mux_sel;

    mux_2_32 cutter_mux(
        .C0(rt_data_out),
        .C1(dmem_out),
        .S0(cutter_mux_sel),
        .oZ(cutter_mux_out)
    );

    cutter cpu_cutter(
        .data_in(cutter_mux_out),
        .sel(cutter_sel),
        .sign(cutter_sign),
        .data_out(mem_dmem_out)
    );

    dmem cpu_dmem(
        .clk(clk),
        .ena(dmem_ena),
        .wena(dmem_wena),
        .w_cs(dmem_w_cs),
        .r_cs(dmem_r_cs),
        .data_in(mem_dmem_out),
        .addr(alu_out),
        .data_out(dmem_out)
    );

endmodule