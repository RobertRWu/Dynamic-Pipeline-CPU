///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Multiplier
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module multiplier(  
    input reset,
    input ena,     
    input sign, 
    input [31:0] a,
    input [31:0] b,
    output [31:0] mul_hi,
    output [31:0] mul_lo
    );

    parameter BIT_NUM = 32;

    reg [31:0] temp_a;
    reg [31:0] temp_b;
    reg [63:0] stored;
    reg [63:0] temp;
    reg is_minus;
    integer i;

    always @(*) 
    begin
        if(reset == `RST_ENABLED) begin
            stored <= 0;
            is_minus <= 0;
            temp_a <= 0;
            temp_b <= 0;
        end

        else if(ena == `ENABLED) begin
            // If multiplicator or multiplicand is 0, the result will be 0
            if (a == 0 || b == 0) begin
                stored <= 0;
            end

            // Unsigned
            else if(sign == `UNSIGNED) begin
                stored = 0;

                for (i = 0; i < 32; i = i + 1) begin
                    temp = b[i] ? ({32'b0, a} << i) : 64'b0;
                    stored = stored + temp;       
                end
            end

            // Signed
            else begin
                stored = 0;
                is_minus = a[31] ^ b[31];   //judge 
                temp_a = a;
                temp_b = b;

                if (a[31] == 1) begin
                    temp_a = a ^ 32'hffffffff;
                    temp_a = temp_a + 1;
                end

                if (b[31] == 1) begin
                    temp_b = b ^ 32'hffffffff;
                    temp_b = temp_b + 1;
                end

                for (i = 0; i < 32; i = i + 1) begin
                    temp = temp_b[i] ? ({32'b0, temp_a} << i) : 64'b0;
                    stored = stored + temp;       
                end

                if (is_minus == 1) begin
                    stored = stored ^ 64'hffffffffffffffff;
                    stored = stored + 1;
                end
            end
        end
    end

    assign mul_hi = (ena == `ENABLED) ? stored[63:32] : 32'b0;
    assign mul_lo = (ena == `ENABLED) ? stored[31:0] : 32'b0;

endmodule
