///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Instruction Fetcher
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pipe_if(
    input [31:0] pc,
    input [31:0] cp0_pc,  // 中断跳转地址  
    input [31:0] b_pc,   // beq bne bgez跳转地址
    input [31:0] r_pc,  // jr jalr跳转地址
    input [31:0] j_pc,  // j jal跳转地址
    input [2:0] pc_mux_sel, 
    output [31:0] npc,  // next pc
    output [31:0] pc4,  // pc + 4
    output [31:0] instruction 
    );

    mux_8_32 next_pc_mux(
        .C0(j_pc), 
        .C1(r_pc), 
        .C2(pc4), 
        .C3(`EXCEPTION_ADDR), 
        .C4(b_pc), 
        .C5(cp0_pc), 
        .C6(32'b0),
        .C7(32'b0),
        .S0(pc_mux_sel), 
        .oZ(npc)
    );

    adder_32 pc_plus4_adder(
        .a(pc), 
        .b(32'h4), 
        .result(pc4)
    );
                      
    imem instruction_mem(pc[12:2], instruction);
    
endmodule