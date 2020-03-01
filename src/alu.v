///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module alu(
    input [31:0] a,    
    input [31:0] b, 
    input [3:0] aluc,
    output [31:0] r,
    output zero,
    output carry, 
    output negative, 
    output overflow
    );

    parameter Addu = 4'b0000;    
    parameter Add = 4'b0010;    
    parameter Subu = 4'b0001;    
    parameter Sub = 4'b0011;    
    parameter And = 4'b0100;    
    parameter Or = 4'b0101;    
    parameter Xor = 4'b0110;    
    parameter Nor = 4'b0111;    
    parameter Lui1 = 4'b1000;    
    parameter Lui2 = 4'b1001;    
    parameter Slt = 4'b1011;    
    parameter Sltu = 4'b1010;    
    parameter Sra = 4'b1100;   
    parameter Sll = 4'b1110;   
    parameter Srl = 4'b1101;    
    parameter Slr = 4'b1111;

    reg [32:0] result;
    reg if_same_signal;
    reg flag;

    always @ (*) begin
        case(aluc)
            Addu: result = a + b;
            Add: begin
                result = $signed(a) + $signed(b);
                if_same_signal = ~(a[31] ^ b[31]);
                flag = (if_same_signal && result[31] != a[31]) ? 1 : 0;
            end
            Subu: result = a - b;
            Sub: begin
                result = $signed(a) - $signed(b);
                if_same_signal = ~(a[31] ^ b[31]);
                flag = (~if_same_signal && result[31] != a[31]) ? 1 : 0;
            end

            And: result = a & b;
            Or: result = a | b;
            Xor: result = a ^ b;
            Nor: result = ~(a | b);

            Lui1: result = {b[15:0], 16'b0};
            Lui2: result = {b[15:0], 16'b0};

            Slt: result = ($signed(a) < $signed(b)) ? 1 : 0;
            Sltu: result =  (a < b) ? 1 : 0;

            Sra: result = $signed(b) >>> a;
            Sll: result = b << a;
            Slr: result = b << a;
            Srl: result = b >> a;
        endcase
    end
    
    assign r = result[31:0];
    assign carry = (aluc == Addu | aluc == Subu | aluc == Sltu | aluc == Sra | aluc == Srl | aluc == Sll) ? result[32] : 1'bz; 
    assign zero = (r == 32'b0) ? 1 : 0; 
    assign negative = result[31];
    assign overflow = (aluc == Add | aluc == Sub) ? flag : 1'bz; 
    
endmodule
