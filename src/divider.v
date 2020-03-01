///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Executor
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module divider(
    //input clk,
    input reset,
    input ena,
    input sign,
    input [31:0] dividend,
    input [31:0] divisor,
    output [31:0] q,  // Quotient
    output [31:0] r   // Remainder
    );

    reg [63:0] temp_dividend;
    reg [63:0] temp_divisor;
    reg is_minus;
    reg is_div_minus;
    integer counter;
    
    always @ (*) 
    begin
        if (reset == `RST_ENABLED) begin
            temp_dividend <= 0;
            temp_divisor <= 0;
            is_minus <= 0;
            is_div_minus <= 0;
        end

        else if(ena == `ENABLED) begin
            // Unsigned
            if(sign == `UNSIGNED) begin
                temp_dividend = dividend;
                temp_divisor = {divisor, 32'b0}; 

                for (counter = 0; counter < 32; counter = counter + 1) begin
                    temp_dividend = temp_dividend << 1;
                            
                    if (temp_dividend >= temp_divisor) begin
                        temp_dividend = temp_dividend - temp_divisor;
                        temp_dividend = temp_dividend + 1;
                    end
                end
                
                counter = 0;
            end

            // Signed
            else begin
                temp_dividend = dividend;
                temp_divisor = {divisor, 32'b0};
                is_minus = dividend[31] ^ divisor[31];   //judge 
                is_div_minus = dividend[31];

                if (dividend[31] == 1) begin
                temp_dividend = dividend ^ 32'hffffffff;
                temp_dividend = temp_dividend + 1;
                end

                if (divisor[31] == 1) begin
                    temp_divisor = {divisor ^ 32'hffffffff, 32'b0};
                    temp_divisor = temp_divisor + 64'h0000000100000000;
                end 
                
                for (counter = 0; counter < 32; counter = counter + 1) begin
                    temp_dividend = temp_dividend << 1;
                    
                    if (temp_dividend >= temp_divisor) begin
                        temp_dividend = temp_dividend - temp_divisor;
                        temp_dividend = temp_dividend + 1;
                    end
                end

                if (is_div_minus == 1) begin
                    temp_dividend = temp_dividend ^ 64'hffffffff00000000;
                    temp_dividend = temp_dividend + 64'h0000000100000000;
                end
                                    
                if (is_minus == 1) begin
                    temp_dividend = temp_dividend ^ 64'h00000000ffffffff;
                    temp_dividend = temp_dividend + 64'h0000000000000001;

                    if (temp_dividend[31:0] == 32'b0) begin
                        temp_dividend = temp_dividend - 64'h0000000100000000;
                    end
                end
            end
        end
    end
    
    assign q = (ena == `CHIP_ENABLED) ? temp_dividend[31:0] : 32'b0;
    assign r = (ena == `CHIP_ENABLED) ? temp_dividend[63:32]: 32'b0;
    
endmodule
