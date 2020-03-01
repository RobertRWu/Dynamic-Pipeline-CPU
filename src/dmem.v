///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Data Memory
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`include "define.v"

module dmem (
    input clk,
    input ena,
    input wena,
    input [1:0] w_cs,
    input [1:0] r_cs, 
    input [31:0] data_in,
    input [31:0] addr,
    output reg [31:0] data_out
    );

    parameter SW = 2'b01;
    parameter SH = 2'b10;
    parameter SB = 2'b11;
    parameter LW = 2'b01;
    parameter LH = 2'b10;
    parameter LB = 2'b11;

    reg [31:0] temp [1023:0];

    // Write
    always @ (posedge clk) 
    begin
        if(ena == `ENABLED) begin
            if(wena == `WRITE_ENABLED) begin
                if(w_cs == SW) begin
                    temp[(addr - 32'h10010000) / 4] <= data_in;
                end

                else if(w_cs == SH) begin
                    case((addr - 32'h10010000) % 4)
                        32'h0: temp[(addr - 32'h10010000) / 4][15:0] <= data_in[15:0];
                        32'h2: temp[(addr - 32'h10010000) / 4][31:16] <= data_in[15:0];
                    endcase
                end

                else begin
                    case((addr - 32'h10010000) % 4)
                        32'h0: temp[(addr - 32'h10010000) / 4][7:0] <= data_in[7:0];
                        32'h1: temp[(addr - 32'h10010000) / 4][15:8] <= data_in[7:0];
                        32'h2: temp[(addr - 32'h10010000) / 4][23:16] <= data_in[7:0];
                        32'h3: temp[(addr - 32'h10010000) / 4][31:24] <= data_in[7:0];
                    endcase
                end
            end
        end
    end
    
    // Read
    always @ (*) 
    begin
        if(ena == `ENABLED && wena == `WRITE_DISABLED) begin
            if(r_cs == LW) begin
                data_out <= temp[(addr - 32'h10010000) / 4];
            end

            else if(r_cs == LH) begin
                case((addr - 32'h10010000) % 4)
                    32'h0: data_out <= temp[(addr - 32'h10010000) / 4][15:0];
                    32'h2: data_out <= temp[(addr - 32'h10010000) / 4][31:16];
                endcase
            end

            else begin
                case((addr - 32'h10010000) % 4)
                    32'h0: data_out <= temp[(addr - 32'h10010000) / 4][7:0];
                    32'h1: data_out <= temp[(addr - 32'h10010000) / 4][15:8];
                    32'h2: data_out <= temp[(addr - 32'h10010000) / 4][23:16];
                    32'h3: data_out <= temp[(addr - 32'h10010000) / 4][31:24];
                endcase
            end 
        end
    end
    
endmodule