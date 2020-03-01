///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Control unit in the cpu
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module control_unit(
    input is_branch,
    input [31:0] instruction,
    input [5:0] op,
    input [5:0] func,
    input [31:0] status,   
    output rf_wena,     
    output hi_wena,
    output lo_wena,
    output dmem_wena, 
    output rf_rena1,
    output rf_rena2,
    output clz_ena,
    output mul_ena,
    output div_ena,
    output dmem_ena,
    output [1:0] dmem_w_cs,
    output [1:0] dmem_r_cs,
    output ext16_sign,
    output cutter_sign,
    output mul_sign,
    output div_sign,
    output [3:0] aluc,
    output [4:0] rd,
    output mfc0,
    output mtc0,
    output eret,
    output exception,
    output [4:0] cp0_addr,
    output [4:0] cause,
    output ext5_mux_sel,
    output cutter_mux_sel,
    output alu_mux1_sel,       
    output [1:0] alu_mux2_sel,
    output [1:0] hi_mux_sel,
    output [1:0] lo_mux_sel,
    output [2:0] cutter_sel,
    output [2:0] rf_mux_sel,
    output [2:0] pc_mux_sel
    );

    wire Addi = (op == 6'b001000);
    wire Addiu = (op == 6'b001001);
    wire Andi = (op == 6'b001100);
    wire Ori = (op == 6'b001101);
    wire Sltiu = (op == 6'b001011);
    wire Lui = (op == 6'b001111);
    wire Xori = (op == 6'b001110);
    wire Slti = (op == 6'b001010);
    wire Addu = (op == 6'b000000 && func==6'b100001);
    wire And = (op == 6'b000000 && func == 6'b100100);
    wire Beq = (op == 6'b000100);
    wire Bne = (op == 6'b000101);
    wire J = (op == 6'b000010);
    wire Jal = (op == 6'b000011);
    wire Jr = (op == 6'b000000 && func == 6'b001000);
    wire Lw = (op == 6'b100011);
    wire Xor = (op == 6'b000000 && func == 6'b100110);
    wire Nor = (op == 6'b000000 && func == 6'b100111);
    wire Or = (op == 6'b000000 && func == 6'b100101);
    wire Sll = (op == 6'b000000 && func == 6'b000000);
    wire Sllv = (op == 6'b000000 && func == 6'b000100);
    wire Sltu = (op == 6'b000000 && func == 6'b101011);
    wire Sra = (op == 6'b000000 && func == 6'b000011);
    wire Srl = (op == 6'b000000 && func == 6'b000010);
    wire Subu = (op == 6'b000000 && func == 6'b100011);
    wire Sw = (op == 6'b101011);
    wire Add = (op == 6'b000000 && func == 6'b100000);
    wire Sub = (op == 6'b000000 && func == 6'b100010);
    wire Slt = (op == 6'b000000 && func == 6'b101010);
    wire Srlv = (op == 6'b000000 && func == 6'b000110);
    wire Srav = (op == 6'b000000 && func == 6'b000111);
    
    wire Clz = (op == 6'b011100 && func == 6'b100000);
    wire Divu = (op == 6'b000000 && func == 6'b011011);
    wire Eret = (op == 6'b010000 && func == 6'b011000);
    wire Jalr = (op == 6'b000000 && func == 6'b001001);
    wire Lb = (op == 6'b100000);
    wire Lbu = (op == 6'b100100);
    wire Lhu = (op == 6'b100101);
    wire Sb = (op == 6'b101000);
    wire Sh = (op == 6'b101001);
    wire Lh = (op == 6'b100001);
    wire Mfc0 = (instruction[31:21] == 11'b01000000000 && instruction[10:3]==8'b00000000);
    wire Mfhi = (op == 6'b000000 && func == 6'b010000);
    wire Mflo = (op == 6'b000000 && func == 6'b010010);
    wire Mtc0 = (instruction[31:21] == 11'b01000000100 && instruction[10:3]==8'b00000000);
    wire Mthi = (op == 6'b000000 && func == 6'b010001);
    wire Mtlo = (op == 6'b000000 && func == 6'b010011);
    wire Mul = (op == 6'b011100 && func == 6'b000010);
    wire Multu = (op == 6'b000000 && func == 6'b011001);
    wire Syscall = (op == 6'b000000 && func== 6'b001100);
    wire Teq = (op == 6'b000000 && func == 6'b110100);
    wire Bgez = (op == 6'b000001);
    wire Break = (op == 6'b000000 && func == 6'b001101);
    wire Div = (op == 6'b000000 && func == 6'b011010);

    assign rf_rena1 = Addi+Addiu+Andi+Ori+Sltiu+Xori+Slti+Addu+And+Beq+Bne+Jr+Lw+Xor+Nor+Or+Sllv+Sltu+Subu+Sw+Add+Sub+Slt+Srlv+Srav+Clz+Divu+Jalr+Lb+Lbu+Lhu+Sb+Sh+Lh+Mul+Multu+Teq+Div;
    assign rf_rena2 = Addu+And+Beq+Bne+Xor+Nor+Or+Sll+Sllv+Sltu+Sra+Srl+Subu+Sw+Add+Sub+Slt+Srlv+Srav+Divu+Sb+Sh+Mtc0+Mul+Multu+Teq+Div;

    assign hi_wena = Div+Divu+Multu+Mthi+Mul;
    assign lo_wena = Div+Divu+Multu+Mtlo+Mul;
    assign rf_wena = Addi+Addiu+Andi+Ori+Sltiu+Lui+Xori+Slti+Addu+And+Xor+Nor+Or+Sll+Sllv+Sltu+Sra+Srl+Subu+Add+Sub+Slt+Srlv+Srav+Lb+Lbu+Lh+Lhu+Lw+Mfc0+Clz+Jal+Jalr+Mfhi+Mflo+Mul;
    assign clz_ena = Clz;
    assign mul_ena = Mul+Multu;
    assign div_ena = Div+Divu;                                     

    assign dmem_wena = Sb+Sh+Sw;
    assign dmem_ena = Lw+Sw+Sb+Sh+Lb+Lh+Lhu+Lbu;
    assign dmem_w_cs[1] = Sh+Sb;
    assign dmem_w_cs[0] = Sw+Sb;
    assign dmem_r_cs[1] = Lh+Lb+Lhu+Lbu;
    assign dmem_r_cs[0] = Lw+Lb+Lbu;     

    assign cutter_sign = Lb+Lh;
    assign mul_sign = Mul;
    assign div_sign = Div;
    assign ext16_sign = Addi+Addiu+Sltiu+Slti;
    
    assign ext5_mux_sel = Sllv+Srav+Srlv;

    assign alu_mux1_sel = ~(Sll+Srl+Sra+Div+Divu+Mul+Multu+J+Jr+Jal+Jalr+Mfc0+Mtc0+Mfhi+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Break);
    assign alu_mux2_sel[1] = Bgez;
    assign alu_mux2_sel[0] = Slti+Sltiu+Addi+Addiu+Andi+Ori+Xori+Lb+Lbu+Lh+Lhu+Lw+Sb+Sh+Sw+Lui;

    assign aluc[3] = Slt+Sltu+Sllv+Srlv+Srav+Lui+Srl+Sra+Slti+Sltiu+Sll;
    assign aluc[2] = And+Or+Xor+Nor+Sll+Srl+Sra+Sllv+Srlv+Srav+Andi+Ori+Xori;
    assign aluc[1] = Add+Sub+Xor+Nor+Slt+Sltu+Sll+Sllv+Addi+Xori+Beq+Bne+Slti+Sltiu+Bgez+Teq;
    assign aluc[0] = Subu+Sub+Or+Nor+Slt+Sllv+Srlv+Sll+Srl+Slti+Ori+Beq+Bne+Bgez+Teq;
    
    assign cutter_mux_sel = ~(Sb+Sh+Sw);
    assign cutter_sel[2] = Sh;
    assign cutter_sel[1] = Lb+Lbu+Sb;
    assign cutter_sel[0] = Lh+Lhu+Sb;

    assign rf_mux_sel[2] = ~(Beq+Bne+Bgez+Div+Divu+Sb+Multu+Sh+Sw+J+Jr+Jal+Jalr+Mfc0+Mtc0+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Teq+Break);
    assign rf_mux_sel[1] = Mul+Mfc0+Mtc0+Clz+Mfhi;
    assign rf_mux_sel[0] = ~(Beq+Bne+Bgez+Div+Divu+Multu+Lb+Lbu+Lh+Lhu+Lw+Sb+Sh+Sw+J+Mtc0+Mfhi+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Teq+Break);
    
    assign pc_mux_sel[2] = Eret+(Beq&&is_branch)+(Bne&&is_branch)+(Bgez&&is_branch);
    assign pc_mux_sel[1] = ~(J+Jr+Jal+Jalr+pc_mux_sel[2]);
    assign pc_mux_sel[0] = Eret+exception+Jr+Jalr;

    assign hi_mux_sel[1] = Mthi;
    assign hi_mux_sel[0] = Mul+Multu;

    assign lo_mux_sel[1] = Mtlo;
    assign lo_mux_sel[0] = Mul+Multu;

    assign rd = (Add+Addu+Sub+Subu+And+Or+Xor+Nor+Slt+Sltu+Sll+Srl+Sra+Sllv+Srlv+Srav+Clz+Jalr+Mfhi+Mflo+Mul) ? 
                   instruction[15:11] : (( Addi+Addiu+Andi+Ori+Xori+Lb+Lbu+Lh+Lhu+Lw+Slti+Sltiu+Lui+Mfc0) ? 
                   instruction[20:16] : (Jal?5'd31:5'b0));

    assign mfc0 = Mfc0;
    assign mtc0 = Mtc0;
    assign cp0_addr = instruction[15:11];
    assign exception = status[0] && ((Syscall && status[1]) || (Break && status[2]) || (Teq && status[3]));
    assign eret = Eret;
    assign cause = Break ? 5'b01001 : (Syscall ? 5'b01000 : (Teq ? 5'b01101 : 5'b00000));

endmodule
