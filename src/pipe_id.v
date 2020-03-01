///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Instruction Decoder
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module pipe_id(
    input clk,
    input rst,
    input [31:0] pc4,  
    input [31:0] instruction,
    input [31:0] rf_wdata,    //data for writing in regfile
    input [31:0] hi_wdata,
    input [31:0] lo_wdata,
    input [4:0] rf_waddr,  // Regfile write address
    input rf_wena,        //writing enable for regfile
    input hi_wena,        //writing enable for hi register
    input lo_wena,        //writing enable for lo register

    // Data from EXE  
	input [4:0] exe_rf_waddr,  
    input exe_rf_wena,
    input exe_hi_wena,
    input exe_lo_wena,
    input [31:0] exe_mul_hi,  // 乘法结果高位
    input [31:0] exe_mul_lo,  // 乘法结果低位
    input [31:0] exe_div_r,  // 余数
    input [31:0] exe_div_q,  // �?
    input [31:0] exe_rs_data_out,
    input [31:0] exe_lo_out,
    input [31:0] exe_pc4,
    input [31:0] exe_clz_out,
    input [31:0] exe_alu_out,
    input [31:0] exe_hi_out,
    input [1:0] exe_hi_mux_sel,
    input [1:0] exe_lo_mux_sel,
    input [2:0] exe_rf_mux_sel,
    input [5:0] exe_op,
    input [5:0] exe_func,

	// Data from MEM
	input [4:0] mem_rf_waddr,  
    input mem_rf_wena,
    input mem_hi_wena,
    input mem_lo_wena,
    input [31:0] mem_mul_hi,
    input [31:0] mem_mul_lo,
    input [31:0] mem_div_r,
    input [31:0] mem_div_q,
    input [31:0] mem_rs_data_out,
    input [31:0] mem_dmem_out,
    input [31:0] mem_lo_out,
    input [31:0] mem_pc4,
    input [31:0] mem_clz_out,
    input [31:0] mem_alu_out,
    input [31:0] mem_hi_out,
    input [1:0] mem_hi_mux_sel,
    input [1:0] mem_lo_mux_sel,
    input [2:0] mem_rf_mux_sel,

    output [31:0] id_cp0_pc,  // Interrupt address
    output [31:0] id_r_pc,
    output [31:0] id_b_pc,  // Jump address
    output [31:0] id_j_pc,  // Beq and Bne address
    output [31:0] id_rs_data_out,  
    output [31:0] id_rt_data_out,
    output [31:0] id_imm,  // Immediate value
    output [31:0] id_shamt,  
    output [31:0] id_pc4,  
    output [31:0] id_cp0_out,    //output data of cp0
    output [31:0] id_hi_out,     //output data of hi register
    output [31:0] id_lo_out,     //output data of lo register
    output [4:0] id_rf_waddr,
    output [3:0] id_aluc,
    output id_mul_sign,
    output id_div_sign,
    output id_cutter_sign,
    output id_clz_ena,
    output id_mul_ena,
    output id_div_ena,
    output id_dmem_ena,
    output id_hi_wena,
    output id_lo_wena,
    output id_rf_wena,
    output id_dmem_wena,
    output [1:0] id_dmem_w_cs,
    output [1:0] id_dmem_r_cs,
    output id_cutter_mux_sel,
    output id_alu_mux1_sel, 
    output [1:0] id_alu_mux2_sel,
    output [1:0] id_hi_mux_sel,
    output [1:0] id_lo_mux_sel,
    output [2:0] id_cutter_sel,
    output [2:0] id_rf_mux_sel,
    output [2:0] id_pc_mux_sel,
    output [5:0] id_op,
    output [5:0] id_func,
    output stall,
    output is_branch,
    output [31:0] reg28,
    output [31:0] reg29
    );

    //Regfile
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;  // Register Destinition
    wire [5:0] op;  // Operand
    wire [5:0] func;  // Function
    wire rf_rena1;  // Regfile read enable 1
    wire rf_rena2;

    wire [15:0] ext16_data_in;  // Input data of extend16
    wire [17:0] ext18_data_in;  // Input data of extend18 
    wire [31:0] ext16_data_out;  // Output data of extend16
    wire [31:0] ext18_data_out;  // Output data of extend18 
    wire ext16_sign;
    wire mfc0;
    wire mtc0;
    wire eret;
    
    // Data forwarding
    wire if_df;
    wire is_rs;
    wire is_rt;
    wire [31:0] df_hi_temp;
    wire [31:0] df_lo_temp;
    wire [31:0] df_rs_temp;
    wire [31:0] df_rt_temp;
    wire [31:0] exe_df_hi_out;
    wire [31:0] exe_df_lo_out;
    wire [31:0] exe_df_rf_wdata;
    wire [31:0] mem_df_hi_out;
    wire [31:0] mem_df_lo_out;
    wire [31:0] mem_df_rf_wdata;
    
    // CP0 ports
    wire cp0_exception;
    wire [4:0] cp0_cause;
    wire [4:0] cp0_addr;
    wire [31:0] cp0_status;

    // Ext5
    wire ext5_mux_sel;
    wire [4:0] ext5_mux_out;
    
    wire [31:0] hi_temp;
    wire [31:0] lo_temp;
    wire [31:0] rs_temp;
    wire [31:0] rt_temp;
    
    assign op = instruction[31:26];
    assign rs = instruction[25:21];
    assign rt = instruction[20:16];
    assign func = instruction[5:0];
    assign ext16_data_in = instruction[15:0];
    assign ext18_data_in = {instruction[15:0], 2'b00};

    assign id_imm = ext16_data_out;
    assign id_j_pc = {pc4[31:28], instruction[25:0], 2'b00};
    assign id_r_pc = id_rs_data_out;
    assign id_pc4 = pc4;
    assign id_rf_waddr = rd;
    assign id_rs_data_out = (if_df && is_rs) ? df_rs_temp : rs_temp;
    assign id_rt_data_out = (if_df && is_rt) ? df_rt_temp : rt_temp;
    assign id_hi_out = if_df ? df_hi_temp : hi_temp;
    assign id_lo_out = if_df ? df_lo_temp : lo_temp;
    assign id_op = op;
    assign id_func = func;


    id_df data_forwarding(
        .clk(clk),
        .rst(rst),
        .op(op),  
        .func(func),
        .rs(rs),
        .rt(rt),
        .rf_rena1(rf_rena1),
        .rf_rena2(rf_rena2),

	    .exe_rf_waddr(exe_rf_waddr),  
        .exe_rf_wena(exe_rf_wena),
        .exe_hi_wena(exe_hi_wena),
        .exe_lo_wena(exe_lo_wena),
        .exe_df_hi_out(exe_df_hi_out),
        .exe_df_lo_out(exe_df_lo_out),
        .exe_df_rf_wdata(exe_df_rf_wdata),
        .exe_op(exe_op),
        .exe_func(exe_func),

        .mem_rf_waddr(mem_rf_waddr),  
        .mem_rf_wena(mem_rf_wena),
        .mem_hi_wena(mem_hi_wena),
        .mem_lo_wena(mem_lo_wena),
        .mem_df_hi_out(mem_df_hi_out),
        .mem_df_lo_out(mem_df_lo_out),
        .mem_df_rf_wdata(mem_df_rf_wdata),

        .rs_data_out(df_rs_temp),  
        .rt_data_out(df_rt_temp),
        .hi_out(df_hi_temp),  
        .lo_out(df_lo_temp),     
        .stall(stall),
        .if_df(if_df),
        .is_rs(is_rs),
        .is_rt(is_rt)
    );


    // MUX for EXE HI data forwarding
    mux_4_32 exe_df_mux_hi(
        .C0(exe_div_r),
        .C1(exe_mul_hi),
        .C2(exe_rs_data_out),
        .C3(32'h0),
        .S0(exe_hi_mux_sel),
        .oZ(exe_df_hi_out)
    );
 
    // MUX for MEM HI data forwarding
    mux_4_32 mem_df_mux_hi(
        .C0(mem_div_r),
        .C1(mem_mul_hi),
        .C2(mem_rs_data_out),
        .C3(32'h0),
        .S0(mem_hi_mux_sel),
        .oZ(mem_df_hi_out)
    );
 
    // MUX for EXE LO data forwarding
    mux_4_32 exe_df_mux_lo(
        .C0(exe_div_q),
        .C1(exe_mul_lo),
        .C2(exe_rs_data_out),
        .C3(32'b0),
        .S0(exe_lo_mux_sel),
        .oZ(exe_df_lo_out)
    );

    // MUX for MEM LO data forwarding
    mux_4_32 mem_df_mux_lo(
        .C0(mem_div_q),
        .C1(mem_mul_lo),
        .C2(mem_rs_data_out),
        .C3(32'b0),
        .S0(mem_lo_mux_sel),
        .oZ(mem_df_lo_out)
    );

    // MUX for EXE Regfile data forwarding
    mux_8_32 exe_df_mux_rf(
        .C0(exe_lo_out),
        .C1(exe_pc4),
        .C2(exe_clz_out),
        .C3(32'b0),
        .C4(32'b0),  // In the EXE phase the cpu hasn't got the value when the instruction is Lw, Lh, Lb
        .C5(exe_alu_out),
        .C6(exe_hi_out),
        .C7(exe_mul_lo),
        .S0(exe_rf_mux_sel),
        .oZ(exe_df_rf_wdata)
    );

    // MUX for MEM Regfile data forwarding
    mux_8_32 mem_df_mux_rf(
        .C0(mem_lo_out),
        .C1(mem_pc4),
        .C2(mem_clz_out),
        .C3(32'b0),
        .C4(mem_dmem_out), 
        .C5(mem_alu_out),
        .C6(mem_hi_out),
        .C7(mem_mul_lo),
        .S0(mem_rf_mux_sel),
        .oZ(mem_df_rf_wdata)
    );


    // MUX for extend5
    mux_2_5 extend5_mux(
        .C0(instruction[10:6]),
        .C1(id_rs_data_out[4:0]),
        .S0(ext5_mux_sel), 
        .oZ(ext5_mux_out)
    );

    // Adder for beq and bne
    adder_32 b_pc_adder(
        .a(pc4),
        .b(ext18_data_out),
        .result(id_b_pc)
    );

    // Extend5 for shamt(sll etc)
    extend_5_32 sa_ext(
        .a(ext5_mux_out),
        .b(id_shamt)
    );

    // Extend16 for immediate
    extend_16_32 imm_ext(
        .data_in(ext16_data_in),
        .sign(ext16_sign),
        .data_out(ext16_data_out)
    );

    // Extend18 for beq and bne
    extend_sign_18_32 ext18_b_pc(
        .data_in(ext18_data_in),
        .data_out(ext18_data_out)
    );

    regfile cpu_regfile(
        .clk(clk), 
        .rst(rst), 
        .wena(rf_wena),
        .raddr1(rs),
        .raddr2(rt),
        .rena1(rf_rena1),
        .rena2(rf_rena2),
        .waddr(rf_waddr),
        .wdata(rf_wdata),
        .rdata1(rs_temp),
        .rdata2(rt_temp),
        .reg28(reg28),
        .reg29(reg29)
    );

    cp0 cpu_cp0(
        .clk(clk), 
        .rst(rst), 
        .mfc0(mfc0),
        .mtc0(mtc0),
        .pc(pc4 - 4),         
        .addr(cp0_addr),
        .wdata(id_rt_data_out),
        .exception(cp0_exception),
        .eret(eret),
        .cause(cp0_cause),
        .rdata(id_cp0_out),
        .status(cp0_status),
        .exc_addr(id_cp0_pc)
    );

    // HI Register
    register hi_reg(
        .clk(clk),
        .rst(rst),
        .wena(hi_wena),
        .data_in(hi_wdata),
        .data_out(hi_temp)
    );

    // LO Register
    register lo_reg(
        .clk(clk),
        .rst(rst),
        .wena(lo_wena),
        .data_in(lo_wdata),
        .data_out(lo_temp)
    );

    // Branch prediction
    branch_compare compare(
        .clk(clk),
        .rst(rst),
        .data_in1(id_rs_data_out),
        .data_in2(id_rt_data_out),
        .op(op),
        .func(func),
        .exception(cp0_exception),
        .is_branch(is_branch)
    );

    control_unit control_unit( 
        .is_branch(is_branch),
        .instruction(instruction),
        .op(op),
        .func(func),
        .status(cp0_status),
        .rf_wena(id_rf_wena),
        .hi_wena(id_hi_wena),
        .lo_wena(id_lo_wena),
        .dmem_wena(id_dmem_wena),
        .rf_rena1(rf_rena1),
        .rf_rena2(rf_rena2),
        .clz_ena(id_clz_ena),
        .mul_ena(id_mul_ena),
        .div_ena(id_div_ena),
        .dmem_ena(id_dmem_ena),
        .dmem_w_cs(id_dmem_w_cs),
        .dmem_r_cs(id_dmem_r_cs),
        .ext16_sign(ext16_sign),
        .cutter_sign(id_cutter_sign),
        .mul_sign(id_mul_sign),
        .div_sign(id_div_sign),
        .aluc(id_aluc),
        .rd(rd),
        .mfc0(mfc0),
        .mtc0(mtc0),
        .eret(eret),
        .exception(cp0_exception),
        .cp0_addr(cp0_addr),
        .cause(cp0_cause),
        .ext5_mux_sel(ext5_mux_sel),
        .cutter_mux_sel(id_cutter_mux_sel),
        .alu_mux1_sel(id_alu_mux1_sel),
        .alu_mux2_sel(id_alu_mux2_sel),
        .hi_mux_sel(id_hi_mux_sel),
        .lo_mux_sel(id_lo_mux_sel),
        .cutter_sel(id_cutter_sel),
        .rf_mux_sel(id_rf_mux_sel),
        .pc_mux_sel(id_pc_mux_sel)
    );

endmodule