///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Top Module
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input rst,
    output [31:0] instruction,
    output [31:0] pc,
    output [31:0] reg28,
    output [31:0] reg29
    );

    // Wires for stall
    wire stall;

    // Wires for branch prediction
    wire is_branch;

    // Wires for pc
    wire pc_wena;


    // Wires for IF
    // IF Input
    wire [31:0] if_pc_i;  // PC + 4
    wire [31:0] if_cp0_pc_i;  // CP0 PC
    wire [31:0] if_b_pc_i;  // BEQ and BNE PC
    wire [31:0] if_r_pc_i;  // Jr and Jalr PC
    wire [31:0] if_j_pc_i;  // j instruction PC
    wire [2:0] if_pc_mux_sel_i;  

    // IF Output
    wire [31:0] if_npc_o; 
    wire [31:0] if_pc4_o;
    wire [31:0] if_instruction_o; 


    // Wires for ID
    // ID Input
    wire [31:0] id_pc4_i;  // PC + 4
    wire [31:0] id_instruction_i;
    wire [31:0] id_rf_wdata_i;    //data for writing in regfile
    wire [31:0] id_hi_wdata_i;
    wire [31:0] id_lo_wdata_i;
    wire [4:0] id_rf_waddr_i;  // Regfile write address
    wire id_rf_wena_i;        //writing enable for regfile
    wire id_hi_wena_i;        //writing enable for hi register
    wire id_lo_wena_i;        //writing enable for lo register

    // ID Output
    wire [31:0] id_cp0_pc_o;  // Interrupt address
    wire [31:0] id_r_pc_o;
    wire [31:0] id_b_pc_o;  // Jump address
    wire [31:0] id_j_pc_o;  // Beq and Bne address
    wire [31:0] id_rs_data_out_o;  
    wire [31:0] id_rt_data_out_o;
    wire [31:0] id_imm_o;  // Immediate value
    wire [31:0] id_shamt_o;
    wire [31:0] id_pc4_o;  
    wire [31:0] id_cp0_out_o;    //output data of cp0
    wire [31:0] id_hi_out_o;     //output data of hi register
    wire [31:0] id_lo_out_o;      //output data of lo register
    wire [4:0] id_rf_waddr_o;
    wire [3:0] id_aluc_o;
    wire id_mul_sign_o;
    wire id_div_sign_o;
    wire id_cutter_sign_o;
    wire id_clz_ena_o;
    wire id_mul_ena_o;
    wire id_div_ena_o;
    wire id_dmem_ena_o;
    wire id_hi_wena_o;
    wire id_lo_wena_o;
    wire id_rf_wena_o;
    wire id_dmem_wena_o;
    wire [1:0] id_dmem_w_cs_o;
    wire [1:0] id_dmem_r_cs_o;
    wire id_cutter_mux_sel_o;
    wire id_alu_mux1_sel_o;
    wire [1:0] id_alu_mux2_sel_o;
    wire [1:0] id_hi_mux_sel_o;
    wire [1:0] id_lo_mux_sel_o;
    wire [2:0] id_cutter_sel_o;
    wire [2:0] id_rf_mux_sel_o;
    wire [2:0] id_pc_mux_sel_o;
    wire [5:0] id_op_o;
    wire [5:0] id_func_o;


    // Wires for EXE
    // EXE Input
    wire [31:0] exe_pc4_i;
    wire [31:0] exe_imm_i;
    wire [31:0] exe_shamt_i;
    wire [31:0] exe_rs_data_out_i;
    wire [31:0] exe_rt_data_out_i;
    wire [31:0] exe_cp0_out_i;
    wire [31:0] exe_hi_out_i;
    wire [31:0] exe_lo_out_i;
    wire [4:0] exe_rf_waddr_i;
    wire [3:0] exe_aluc_i;  
    wire exe_mul_ena_i;
    wire exe_div_ena_i;
    wire exe_clz_ena_i;
    wire exe_dmem_ena_i;
    wire [1:0] exe_dmem_w_cs_i;
    wire [1:0] exe_dmem_r_cs_i;
    wire exe_mul_sign_i;
    wire exe_div_sign_i;
    wire exe_cutter_sign_i;
    wire exe_rf_wena_i;       
    wire exe_hi_wena_i;     
    wire exe_lo_wena_i;    
    wire exe_dmem_wena_i;
    wire exe_cutter_mux_sel_i;
    wire exe_alu_mux1_sel_i;
    wire [1:0] exe_alu_mux2_sel_i;
    wire [2:0] exe_cutter_sel_i;
    wire [1:0] exe_hi_mux_sel_i;
    wire [1:0] exe_lo_mux_sel_i;
    wire [2:0] exe_rf_mux_sel_i; 
    wire [5:0] exe_op_i;
    wire [5:0] exe_func_i;

    // EXE Output
    wire [31:0] exe_mul_hi_o;  // Higher bits of the multiplication result
    wire [31:0] exe_mul_lo_o;  // Lower bits of the multiplication result
    wire [31:0] exe_div_r_o;  // Remainder of the division result
    wire [31:0] exe_div_q_o;  // Quotient of the division result
    wire [31:0] exe_clz_out_o;
    wire [31:0] exe_alu_out_o;  // Result of ALU
    wire [31:0] exe_pc4_o;
    wire [31:0] exe_rs_data_out_o;
    wire [31:0] exe_rt_data_out_o;
    wire [31:0] exe_cp0_out_o;
    wire [31:0] exe_hi_out_o;
    wire [31:0] exe_lo_out_o;
    wire [4:0] exe_rf_waddr_o;
    wire exe_dmem_ena_o;
    wire exe_cutter_sign_o;
    wire exe_rf_wena_o;       
    wire exe_hi_wena_o;     
    wire exe_lo_wena_o;    
    wire exe_dmem_wena_o;
    wire [1:0] exe_dmem_w_cs_o;
    wire [1:0] exe_dmem_r_cs_o;
    wire exe_cutter_mux_sel_o;
    wire [2:0] exe_cutter_sel_o;
    wire [1:0] exe_hi_mux_sel_o;
    wire [1:0] exe_lo_mux_sel_o;
    wire [2:0] exe_rf_mux_sel_o;


    // Wires for MEM
    // MEM Input
    wire [31:0] mem_mul_hi_i;
    wire [31:0] mem_mul_lo_i;  
    wire [31:0] mem_div_r_i;
    wire [31:0] mem_div_q_i;  
    wire [31:0] mem_clz_out_i;
    wire [31:0] mem_alu_out_i; 
    wire [31:0] mem_pc4_i;
    wire [31:0] mem_rs_data_out_i;
    wire [31:0] mem_rt_data_out_i;
    wire [31:0] mem_cp0_out_i;
    wire [31:0] mem_hi_out_i;
    wire [31:0] mem_lo_out_i; 
    wire [4:0] mem_rf_waddr_i;
    wire mem_dmem_ena_i;
    wire mem_rf_wena_i;       
    wire mem_hi_wena_i;     
    wire mem_lo_wena_i;    
    wire mem_dmem_wena_i;
    wire mem_cutter_sign_i;
    wire [1:0] mem_dmem_w_cs_i;
    wire [1:0] mem_dmem_r_cs_i;
    wire mem_cutter_mux_sel_i;
    wire [2:0] mem_cutter_sel_i;
    wire [1:0] mem_hi_mux_sel_i;
    wire [1:0] mem_lo_mux_sel_i;
    wire [2:0] mem_rf_mux_sel_i; 

    // MEM Output
    wire [31:0] mem_mul_hi_o;  // Higher bits of the multiplication result
    wire [31:0] mem_mul_lo_o;  // Lower bits of the multiplication result
    wire [31:0] mem_div_r_o;  // Remainder of the division result
    wire [31:0] mem_div_q_o;  // Quotient of the division result
    wire [31:0] mem_clz_out_o;
    wire [31:0] mem_alu_out_o;  // Result of ALU
    wire [31:0] mem_dmem_out_o;
    wire [31:0] mem_pc4_o;
    wire [31:0] mem_rs_data_out_o;
    wire [31:0] mem_cp0_out_o;
    wire [31:0] mem_hi_out_o;
    wire [31:0] mem_lo_out_o;
    wire [4:0] mem_rf_waddr_o;
    wire mem_rf_wena_o;       
    wire mem_hi_wena_o;     
    wire mem_lo_wena_o;    
    wire [1:0] mem_hi_mux_sel_o;
    wire [1:0] mem_lo_mux_sel_o;
    wire [2:0] mem_rf_mux_sel_o;


    // Wires for WB
    // WB Input
    wire [31:0] wb_mul_hi_i;
    wire [31:0] wb_mul_lo_i;  
    wire [31:0] wb_div_r_i;
    wire [31:0] wb_div_q_i;  
    wire [31:0] wb_clz_out_i;
    wire [31:0] wb_alu_out_i; 
    wire [31:0] wb_dmem_out_i;
    wire [31:0] wb_pc4_i;
    wire [31:0] wb_rs_data_out_i;
    wire [31:0] wb_cp0_out_i;
    wire [31:0] wb_hi_out_i;
    wire [31:0] wb_lo_out_i; 
    wire [4:0] wb_rf_waddr_i;
    wire wb_rf_wena_i;       
    wire wb_hi_wena_i;     
    wire wb_lo_wena_i;    
    wire [1:0] wb_hi_mux_sel_i;
    wire [1:0] wb_lo_mux_sel_i;
    wire [2:0] wb_rf_mux_sel_i; 

    // WB Output
    wire [31:0] wb_hi_wdata_o;
    wire [31:0] wb_lo_wdata_o;
    wire [31:0] wb_rf_wdata_o;
    wire [4:0] wb_rf_waddr_o;
    wire wb_rf_wena_o;       
    wire wb_hi_wena_o;     
    wire wb_lo_wena_o;    

    wire id_exe_wena;
    wire exe_mem_wena;
    wire mem_wb_wena;

    assign instruction = if_instruction_o;
    assign pc = if_pc_i;
    assign pc_wena = 1'b1;
    assign id_exe_wena = 1'b1;
    assign exe_mem_wena = 1'b1;
    assign mem_wb_wena = 1'b1;
    
    assign if_pc_mux_sel_i = id_pc_mux_sel_o;
    assign if_cp0_pc_i = id_cp0_pc_o;
    assign if_b_pc_i = id_b_pc_o;
    assign if_r_pc_i = id_r_pc_o;
    assign if_j_pc_i = id_j_pc_o;
    
    assign id_rf_wdata_i = wb_rf_wdata_o;
    assign id_hi_wdata_i = wb_hi_wdata_o;
    assign id_lo_wdata_i = wb_lo_wdata_o;
    assign id_rf_waddr_i = wb_rf_waddr_o;
    assign id_rf_wena_i = wb_rf_wena_o;
    assign id_hi_wena_i = wb_hi_wena_o;
    assign id_lo_wena_i = wb_lo_wena_o;

    pc_reg program_counter(
        .clk(clk),
        .rst(rst),
        .wena(pc_wena),
        .stall(stall),
        .data_in(if_npc_o),
        .data_out(if_pc_i)
    );

    pipe_if instruction_fetch(
        .pc(if_pc_i),
        .cp0_pc(if_cp0_pc_i), 
        .b_pc(if_b_pc_i),
        .r_pc(if_r_pc_i),
        .j_pc(if_j_pc_i),  
        .pc_mux_sel(if_pc_mux_sel_i), 
        .npc(if_npc_o),  
        .pc4(if_pc4_o),  
        .instruction(if_instruction_o) 
    );

    pipe_if_id_reg if_id_reg(
        .clk(clk),
        .rst(rst),
        .if_pc4(if_pc4_o),
        .if_instruction(if_instruction_o),
        .stall(stall),
        .is_branch(is_branch),
        .id_pc4(id_pc4_i),
        .id_instruction(id_instruction_i)
    );

    pipe_id instruction_decoder(
        .clk(clk),
        .rst(rst),
        .pc4(id_pc4_i),
        .instruction(id_instruction_i), 
        .rf_wdata(id_rf_wdata_i),
        .hi_wdata(id_hi_wdata_i),
        .lo_wdata(id_lo_wdata_i),
        .rf_waddr(id_rf_waddr_i),
        .rf_wena(id_rf_wena_i),
        .hi_wena(id_hi_wena_i),
        .lo_wena(id_lo_wena_i),

        .exe_rf_waddr(exe_rf_waddr_o),
        .exe_rf_wena(exe_rf_wena_o),
        .exe_hi_wena(exe_hi_wena_o),
        .exe_lo_wena(exe_lo_wena_o),
        .exe_mul_hi(exe_mul_hi_o),
        .exe_mul_lo(exe_mul_lo_o),
        .exe_div_r(exe_div_r_o),
        .exe_div_q(exe_div_q_o),
        .exe_rs_data_out(exe_rs_data_out_o),
        .exe_lo_out(exe_lo_out_o),
        .exe_pc4(exe_pc4_o),
        .exe_clz_out(exe_clz_out_o),
        .exe_alu_out(exe_alu_out_o),
        .exe_hi_out(exe_hi_out_o),
        .exe_hi_mux_sel(exe_hi_mux_sel_o),
        .exe_lo_mux_sel(exe_lo_mux_sel_o),
        .exe_rf_mux_sel(exe_rf_mux_sel_o),
        .exe_op(exe_op_i),
        .exe_func(exe_func_i),

        // Data from MEM
        .mem_rf_waddr(mem_rf_waddr_o),  
        .mem_rf_wena(mem_rf_wena_o),
        .mem_hi_wena(mem_hi_wena_o),
        .mem_lo_wena(mem_lo_wena_o),
        .mem_mul_hi(mem_mul_hi_o),
        .mem_mul_lo(mem_mul_lo_o),
        .mem_div_r(mem_div_r_o),
        .mem_div_q(mem_div_q_o),
        .mem_rs_data_out(mem_rs_data_out_o),
        .mem_dmem_out(mem_dmem_out_o),
        .mem_lo_out(mem_lo_out_o),
        .mem_pc4(mem_pc4_o),
        .mem_clz_out(mem_clz_out_o),
        .mem_alu_out(mem_alu_out_o),
        .mem_hi_out(mem_hi_out_o),
        .mem_hi_mux_sel(mem_hi_mux_sel_o),
        .mem_lo_mux_sel(mem_lo_mux_sel_o),
        .mem_rf_mux_sel(mem_rf_mux_sel_o),

        .id_cp0_pc(id_cp0_pc_o), 
        .id_r_pc(id_r_pc_o),
        .id_b_pc(id_b_pc_o),  
        .id_j_pc(id_j_pc_o),  
        .id_rs_data_out(id_rs_data_out_o),  
        .id_rt_data_out(id_rt_data_out_o),
        .id_imm(id_imm_o), 
        .id_shamt(id_shamt_o),  
        .id_pc4(id_pc4_o),  
        .id_cp0_out(id_cp0_out_o),    
        .id_hi_out(id_hi_out_o),     
        .id_lo_out(id_lo_out_o),    
        .id_rf_waddr(id_rf_waddr_o),
        .id_aluc(id_aluc_o),
        .id_mul_sign(id_mul_sign_o),
        .id_div_sign(id_div_sign_o),
        .id_cutter_sign(id_cutter_sign_o),
        .id_clz_ena(id_clz_ena_o),
        .id_mul_ena(id_mul_ena_o),
        .id_div_ena(id_div_ena_o),
        .id_dmem_ena(id_dmem_ena_o),
        .id_hi_wena(id_hi_wena_o),
        .id_lo_wena(id_lo_wena_o),
        .id_rf_wena(id_rf_wena_o),
        .id_dmem_wena(id_dmem_wena_o),
        .id_dmem_w_cs(id_dmem_w_cs_o),
        .id_dmem_r_cs(id_dmem_r_cs_o),
        .id_cutter_mux_sel(id_cutter_mux_sel_o),
        .id_alu_mux1_sel(id_alu_mux1_sel_o), 
        .id_alu_mux2_sel(id_alu_mux2_sel_o),
        .id_hi_mux_sel(id_hi_mux_sel_o),
        .id_lo_mux_sel(id_lo_mux_sel_o),
        .id_cutter_sel(id_cutter_sel_o),
        .id_rf_mux_sel(id_rf_mux_sel_o),
        .id_pc_mux_sel(id_pc_mux_sel_o),
        .id_op(id_op_o),
        .id_func(id_func_o),
        .stall(stall),
        .is_branch(is_branch),
        .reg28(reg28),
        .reg29(reg29)
    );

    pipe_id_exe_reg id_exe_reg(
        .clk(clk),
        .rst(rst),
        .wena(id_exe_wena),
        .id_pc4(id_pc4_o),  
        .id_rs_data_out(id_rs_data_out_o),
        .id_rt_data_out(id_rt_data_out_o),
        .id_imm(id_imm_o), 
        .id_shamt(id_shamt_o),
        .id_cp0_out(id_cp0_out_o),  
        .id_hi_out(id_hi_out_o), 
        .id_lo_out(id_lo_out_o),  
        .id_rf_waddr(id_rf_waddr_o),
        .id_clz_ena(id_clz_ena_o),
        .id_mul_ena(id_mul_ena_o),
        .id_div_ena(id_div_ena_o),
        .id_dmem_ena(id_dmem_ena_o),
        .id_mul_sign(id_mul_sign_o),
        .id_div_sign(id_div_sign_o),
        .id_cutter_sign(id_cutter_sign_o),
        .id_aluc(id_aluc_o),  
        .id_rf_wena(id_rf_wena_o),  
        .id_hi_wena(id_hi_wena_o),
        .id_lo_wena(id_lo_wena_o),
        .id_dmem_wena(id_dmem_wena_o),
        .id_dmem_w_cs(id_dmem_w_cs_o),
        .id_dmem_r_cs(id_dmem_r_cs_o),
        .stall(stall),
        .id_cutter_mux_sel(id_cutter_mux_sel_o),
        .id_alu_mux1_sel(id_alu_mux1_sel_o),
        .id_alu_mux2_sel(id_alu_mux2_sel_o),
        .id_hi_mux_sel(id_hi_mux_sel_o),
        .id_lo_mux_sel(id_lo_mux_sel_o),
        .id_cutter_sel(id_cutter_sel_o),
        .id_rf_mux_sel(id_rf_mux_sel_o), 
        .id_op(id_op_o),
        .id_func(id_func_o),
        .exe_pc4(exe_pc4_i),
        .exe_rs_data_out(exe_rs_data_out_i),
        .exe_rt_data_out(exe_rt_data_out_i),
        .exe_imm(exe_imm_i),
        .exe_shamt(exe_shamt_i),
        .exe_cp0_out(exe_cp0_out_i),
        .exe_hi_out(exe_hi_out_i),
        .exe_lo_out(exe_lo_out_i),
        .exe_rf_waddr(exe_rf_waddr_i),
        .exe_clz_ena(exe_clz_ena_i),
        .exe_mul_ena(exe_mul_ena_i),
        .exe_div_ena(exe_div_ena_i),
        .exe_dmem_ena(exe_dmem_ena_i),
        .exe_mul_sign(exe_mul_sign_i),
        .exe_div_sign(exe_div_sign_i),
        .exe_cutter_sign(exe_cutter_sign_i),
        .exe_aluc(exe_aluc_i),
        .exe_rf_wena(exe_rf_wena_i),  
        .exe_hi_wena(exe_hi_wena_i),
        .exe_lo_wena(exe_lo_wena_i),
        .exe_dmem_wena(exe_dmem_wena_i),
        .exe_dmem_w_cs(exe_dmem_w_cs_i),
        .exe_dmem_r_cs(exe_dmem_r_cs_i),
        .exe_alu_mux1_sel(exe_alu_mux1_sel_i),
        .exe_alu_mux2_sel(exe_alu_mux2_sel_i),
        .exe_cutter_mux_sel(exe_cutter_mux_sel_i),
        .exe_hi_mux_sel(exe_hi_mux_sel_i),
        .exe_lo_mux_sel(exe_lo_mux_sel_i),
        .exe_cutter_sel(exe_cutter_sel_i),
        .exe_rf_mux_sel(exe_rf_mux_sel_i),
        .exe_op(exe_op_i),
        .exe_func(exe_func_i)
    );

    pipe_exe executor(
        .rst(rst),
        .pc4(exe_pc4_i),
        .rs_data_out(exe_rs_data_out_i),
        .rt_data_out(exe_rt_data_out_i),
        .imm(exe_imm_i),
        .shamt(exe_shamt_i),
        .cp0_out(exe_cp0_out_i),
        .hi_out(exe_hi_out_i),
        .lo_out(exe_lo_out_i),
        .rf_waddr(exe_rf_waddr_i),
        .aluc(exe_aluc_i),  
        .mul_ena(exe_mul_ena_i),
        .div_ena(exe_div_ena_i),
        .clz_ena(exe_clz_ena_i),
        .dmem_ena(exe_dmem_ena_i),
        .mul_sign(exe_mul_sign_i),
        .div_sign(exe_div_sign_i),
        .cutter_sign(exe_cutter_sign_i),
        .rf_wena(exe_rf_wena_i),       
        .hi_wena(exe_hi_wena_i),     
        .lo_wena(exe_lo_wena_i),   
        .dmem_wena(exe_dmem_wena_i),
        .dmem_w_cs(exe_dmem_w_cs_i),
        .dmem_r_cs(exe_dmem_r_cs_i),
        .cutter_mux_sel(exe_cutter_mux_sel_i),  
        .alu_mux1_sel(exe_alu_mux1_sel_i),
        .alu_mux2_sel(exe_alu_mux2_sel_i),
        .hi_mux_sel(exe_hi_mux_sel_i),
        .lo_mux_sel(exe_lo_mux_sel_i),
        .cutter_sel(exe_cutter_sel_i),
        .rf_mux_sel(exe_rf_mux_sel_i), 
        .exe_mul_hi(exe_mul_hi_o),
        .exe_mul_lo(exe_mul_lo_o),  
        .exe_div_r(exe_div_r_o),  
        .exe_div_q(exe_div_q_o),   
        .exe_clz_out(exe_clz_out_o), 
        .exe_alu_out(exe_alu_out_o),  
        .exe_pc4(exe_pc4_o),
        .exe_rs_data_out(exe_rs_data_out_o),
        .exe_rt_data_out(exe_rt_data_out_o),
        .exe_cp0_out(exe_cp0_out_o),
        .exe_hi_out(exe_hi_out_o),
        .exe_lo_out(exe_lo_out_o),
        .exe_rf_waddr(exe_rf_waddr_o),
        .exe_dmem_ena(exe_dmem_ena_o),
        .exe_rf_wena(exe_rf_wena_o),       
        .exe_hi_wena(exe_hi_wena_o),     
        .exe_lo_wena(exe_lo_wena_o),    
        .exe_dmem_wena(exe_dmem_wena_o),
        .exe_dmem_w_cs(exe_dmem_w_cs_o),
        .exe_dmem_r_cs(exe_dmem_r_cs_o),
        .exe_cutter_sign(exe_cutter_sign_o),
        .exe_cutter_mux_sel(exe_cutter_mux_sel_o),
        .exe_cutter_sel(exe_cutter_sel_o),
        .exe_hi_mux_sel(exe_hi_mux_sel_o),
        .exe_lo_mux_sel(exe_lo_mux_sel_o),
        .exe_rf_mux_sel(exe_rf_mux_sel_o)
    );


    pipe_exe_mem_reg exe_mem_reg(
        .clk(clk),
        .rst(rst),
        .wena(exe_mem_wena),
        .exe_mul_hi(exe_mul_hi_o),
        .exe_mul_lo(exe_mul_lo_o),  
        .exe_div_r(exe_div_r_o),
        .exe_div_q(exe_div_q_o),  
        .exe_clz_out(exe_clz_out_o),
        .exe_alu_out(exe_alu_out_o), 
        .exe_pc4(exe_pc4_o),
        .exe_rs_data_out(exe_rs_data_out_o),
        .exe_rt_data_out(exe_rt_data_out_o),
        .exe_cp0_out(exe_cp0_out_o),
        .exe_hi_out(exe_hi_out_o),
        .exe_lo_out(exe_lo_out_o),
        .exe_rf_waddr(exe_rf_waddr_o),
        .exe_dmem_ena(exe_dmem_ena_o),
        .exe_cutter_sign(exe_cutter_sign_o),
        .exe_rf_wena(exe_rf_wena_o),       
        .exe_hi_wena(exe_hi_wena_o),     
        .exe_lo_wena(exe_lo_wena_o),
        .exe_dmem_wena(exe_dmem_wena_o),
        .exe_dmem_w_cs(exe_dmem_w_cs_o),
        .exe_dmem_r_cs(exe_dmem_r_cs_o),
        .exe_cutter_mux_sel(exe_cutter_mux_sel_o),
        .exe_hi_mux_sel(exe_hi_mux_sel_o),
        .exe_lo_mux_sel(exe_lo_mux_sel_o),
        .exe_cutter_sel(exe_cutter_sel_o),
        .exe_rf_mux_sel(exe_rf_mux_sel_o), 
        .mem_mul_hi(mem_mul_hi_i),
        .mem_mul_lo(mem_mul_lo_i),  
        .mem_div_r(mem_div_r_i),
        .mem_div_q(mem_div_q_i),  
        .mem_clz_out(mem_clz_out_i),
        .mem_alu_out(mem_alu_out_i), 
        .mem_pc4(mem_pc4_i),
        .mem_rs_data_out(mem_rs_data_out_i),
        .mem_rt_data_out(mem_rt_data_out_i),
        .mem_cp0_out(mem_cp0_out_i),
        .mem_hi_out(mem_hi_out_i),
        .mem_lo_out(mem_lo_out_i),
        .mem_rf_waddr(mem_rf_waddr_i),
        .mem_dmem_ena(mem_dmem_ena_i),
        .mem_cutter_sign(mem_cutter_sign_i),
        .mem_rf_wena(mem_rf_wena_i),       
        .mem_hi_wena(mem_hi_wena_i),     
        .mem_lo_wena(mem_lo_wena_i),
        .mem_dmem_wena(mem_dmem_wena_i),
        .mem_dmem_w_cs(mem_dmem_w_cs_i),
        .mem_dmem_r_cs(mem_dmem_r_cs_i),
        .mem_cutter_mux_sel(mem_cutter_mux_sel_i),
        .mem_hi_mux_sel(mem_hi_mux_sel_i),
        .mem_lo_mux_sel(mem_lo_mux_sel_i),
        .mem_cutter_sel(mem_cutter_sel_i),
        .mem_rf_mux_sel(mem_rf_mux_sel_i)
    );

    pipe_mem memory(
        .clk(clk),
        .mul_hi(mem_mul_hi_i),
        .mul_lo(mem_mul_lo_i),  
        .div_r(mem_div_r_i),
        .div_q(mem_div_q_i),  
        .clz_out(mem_clz_out_i),
        .alu_out(mem_alu_out_i), 
        .pc4(mem_pc4_i),
        .rs_data_out(mem_rs_data_out_i),
        .rt_data_out(mem_rt_data_out_i),
        .cp0_out(mem_cp0_out_i),
        .hi_out(mem_hi_out_i),
        .lo_out(mem_lo_out_i), 
        .rf_waddr(mem_rf_waddr_i),
        .dmem_ena(mem_dmem_ena_i),
        .rf_wena(mem_rf_wena_i),       
        .hi_wena(mem_hi_wena_i),     
        .lo_wena(mem_lo_wena_i),    
        .dmem_wena(mem_dmem_wena_i),
        .cutter_sign(mem_cutter_sign_i),
        .dmem_w_cs(mem_dmem_w_cs_i),
        .dmem_r_cs(mem_dmem_r_cs_i),
        .cutter_mux_sel(mem_cutter_mux_sel_i),
        .cutter_sel(mem_cutter_sel_i),
        .hi_mux_sel(mem_hi_mux_sel_i),
        .lo_mux_sel(mem_lo_mux_sel_i),
        .rf_mux_sel(mem_rf_mux_sel_i), 

        .mem_mul_hi(mem_mul_hi_o),  
        .mem_mul_lo(mem_mul_lo_o),  
        .mem_div_r(mem_div_r_o),  
        .mem_div_q(mem_div_q_o),  
        .mem_clz_out(mem_clz_out_o),
        .mem_alu_out(mem_alu_out_o),  
        .mem_dmem_out(mem_dmem_out_o),
        .mem_pc4(mem_pc4_o),
        .mem_rs_data_out(mem_rs_data_out_o),
        .mem_cp0_out(mem_cp0_out_o),
        .mem_hi_out(mem_hi_out_o),
        .mem_lo_out(mem_lo_out_o),
        .mem_rf_waddr(mem_rf_waddr_o),
        .mem_rf_wena(mem_rf_wena_o),       
        .mem_hi_wena(mem_hi_wena_o),     
        .mem_lo_wena(mem_lo_wena_o),    
        .mem_hi_mux_sel(mem_hi_mux_sel_o),
        .mem_lo_mux_sel(mem_lo_mux_sel_o),
        .mem_rf_mux_sel(mem_rf_mux_sel_o)
    );

    pipe_mem_wb_reg mem_wb_reg(
        .clk(clk),
        .rst(rst),
        .wena(mem_wb_wena),
        .mem_mul_hi(mem_mul_hi_o),
        .mem_mul_lo(mem_mul_lo_o),  
        .mem_div_r(mem_div_r_o),
        .mem_div_q(mem_div_q_o),  
        .mem_clz_out(mem_clz_out_o),
        .mem_alu_out(mem_alu_out_o),
        .mem_dmem_out(mem_dmem_out_o), 
        .mem_pc4(mem_pc4_o),
        .mem_rs_data_out(mem_rs_data_out_o),
        .mem_cp0_out(mem_cp0_out_o),
        .mem_hi_out(mem_hi_out_o),
        .mem_lo_out(mem_lo_out_o),
        .mem_rf_waddr(mem_rf_waddr_o),
        .mem_rf_wena(mem_rf_wena_o),       
        .mem_hi_wena(mem_hi_wena_o),     
        .mem_lo_wena(mem_lo_wena_o),
        .mem_hi_mux_sel(mem_hi_mux_sel_o),
        .mem_lo_mux_sel(mem_lo_mux_sel_o),
        .mem_rf_mux_sel(mem_rf_mux_sel_o), 
        .wb_mul_hi(wb_mul_hi_i),
        .wb_mul_lo(wb_mul_lo_i),  
        .wb_div_r(wb_div_r_i),
        .wb_div_q(wb_div_q_i), 
        .wb_clz_out(wb_clz_out_i), 
        .wb_alu_out(wb_alu_out_i),
        .wb_dmem_out(wb_dmem_out_i), 
        .wb_pc4(wb_pc4_i),
        .wb_rs_data_out(wb_rs_data_out_i),
        .wb_cp0_out(wb_cp0_out_i),
        .wb_hi_out(wb_hi_out_i),
        .wb_lo_out(wb_lo_out_i),
        .wb_rf_waddr(wb_rf_waddr_i),
        .wb_rf_wena(wb_rf_wena_i),       
        .wb_hi_wena(wb_hi_wena_i),     
        .wb_lo_wena(wb_lo_wena_i),
        .wb_hi_mux_sel(wb_hi_mux_sel_i),
        .wb_lo_mux_sel(wb_lo_mux_sel_i),
        .wb_rf_mux_sel(wb_rf_mux_sel_i)
    );

    pipe_wb write_back(
        .mul_hi(wb_mul_hi_i),
        .mul_lo(wb_mul_lo_i),  
        .div_r(wb_div_q_i),
        .div_q(wb_div_q_i),  
        .clz_out(wb_clz_out_i),
        .alu_out(wb_alu_out_i), 
        .dmem_out(wb_dmem_out_i),
        .pc4(wb_pc4_i),
        .rs_data_out(wb_rs_data_out_i),
        .cp0_out(wb_cp0_out_i),
        .hi_out(wb_hi_out_i),
        .lo_out(wb_lo_out_i), 
        .rf_waddr(wb_rf_waddr_i),
        .rf_wena(wb_rf_wena_i),       
        .hi_wena(wb_hi_wena_i),     
        .lo_wena(wb_lo_wena_i),    
        .hi_mux_sel(wb_hi_mux_sel_i),
        .lo_mux_sel(wb_lo_mux_sel_i),
        .rf_mux_sel(wb_rf_mux_sel_i), 

        .hi_wdata(wb_hi_wdata_o),  
        .lo_wdata(wb_lo_wdata_o),  
        .rf_wdata(wb_rf_wdata_o),  
        .wb_rf_waddr(wb_rf_waddr_o),
        .wb_rf_wena(wb_rf_wena_o),       
        .wb_hi_wena(wb_hi_wena_o),     
        .wb_lo_wena(wb_lo_wena_o)    
    );

endmodule