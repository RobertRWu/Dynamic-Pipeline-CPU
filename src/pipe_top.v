///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Control unit in the cpu
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps


module pipe_top(
    input clk,
    input rst,
    input switch_res,
    //output [31:0] instruction,
    //output [31:0] pc,
    //output [31:0] res,
    output [7:0] o_seg,
    output [7:0] o_sel
    );

    parameter T1s = 99_999;

    reg [30:0] count;
    reg clk_1s;

    wire [31:0] instruction;
    wire [31:0] pc;
    wire [31:0] reg28;
    wire [31:0] reg29;
    wire [31:0] seg7_in;

    always @ (posedge clk or posedge rst) 
    begin
        if(rst) begin
            clk_1s <= 0;
            count <= 0;
        end
        else if(count == T1s) begin
            count <= 0;
            clk_1s <= ~clk_1s;
        end
        else
            count <= count + 1;
    end

    cpu_top cpu(
        .clk(clk_1s),
        .rst(rst),
        .instruction(instruction),
        .pc(pc),
        .reg28(reg28),
        .reg29(reg29)
    );

    mux_2_32 res_mux(
        .C0(reg28),
        .C1(reg29),
        .S0(switch_res),
        .oZ(seg7_in)
    );

    seg7x16 seg7(clk, rst, 1, seg7_in, o_seg, o_sel);

endmodule
