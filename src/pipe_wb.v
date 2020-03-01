///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Write back module
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pipe_wb(
    input [31:0] mul_hi,
    input [31:0] mul_lo,  
    input [31:0] div_r,
    input [31:0] div_q,  
    input [31:0] clz_out,
    input [31:0] alu_out,
    input [31:0] dmem_out, 
    input [31:0] pc4,
    input [31:0] rs_data_out,
    input [31:0] cp0_out,
    input [31:0] hi_out,
    input [31:0] lo_out, 
    input [4:0] rf_waddr,
    input rf_wena,       
    input hi_wena,     
    input lo_wena,    
    input [1:0] hi_mux_sel,
    input [1:0] lo_mux_sel,
    input [2:0] rf_mux_sel, 
    output [31:0] hi_wdata,
    output [31:0] lo_wdata,
    output [31:0] rf_wdata,
    output [4:0] wb_rf_waddr,
    output wb_rf_wena,       
    output wb_hi_wena,     
    output wb_lo_wena 
    );

    // MUX for HI register
    mux_4_32 mux_hi(
        .C0(div_r),
        .C1(mul_hi),
        .C2(rs_data_out),
        .C3(32'h0),
        .S0(hi_mux_sel),
        .oZ(hi_wdata)
    );
 
    // MUX for LO register
    mux_4_32 mux_lo(
        .C0(div_q),
        .C1(mul_lo),
        .C2(rs_data_out),
        .C3(32'b0),
        .S0(lo_mux_sel),
        .oZ(lo_wdata)
    );

    // MUX for regfile
    mux_8_32 mux_rf(
        .C0(lo_out),
        .C1(pc4),
        .C2(clz_out),
        .C3(cp0_out),
        .C4(dmem_out),
        .C5(alu_out),
        .C6(hi_out),
        .C7(mul_lo),
        .S0(rf_mux_sel),
        .oZ(rf_wdata)
    );

    assign wb_rf_waddr = rf_waddr;
    assign wb_rf_wena = rf_wena;
    assign wb_hi_wena = hi_wena;
    assign wb_lo_wena = lo_wena;

endmodule