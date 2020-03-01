///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: CP0
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module cp0(
    input clk,
    input rst,
    input mfc0,
    input mtc0,
    input [31:0] pc,
    input [4:0] addr,
    input [31:0] wdata,
    input exception,
    input eret,
    input [4:0] cause,
    output [31:0] rdata,
    output [31:0] status,
    output [31:0] exc_addr
    );


    reg [31:0] register [31:0];
    reg [31:0] temp_status;
    integer i;

    always @ (posedge clk or posedge rst) 
    begin
        if (rst == `RST_ENABLED) begin
            for(i = 0; i < 32; i = i + 1) begin
                if(i == `STATUS)
                    register[i] <= 32'h0000000f;
                else
                    register[i] <= 0;
            end
            temp_status <= 0;
        end

        else begin
            if(mtc0)
                register[addr] <= wdata;

            else if(exception) begin
                register[`EPC] = pc;
                temp_status = register[`STATUS];
                register[`STATUS] = register[`STATUS] << 5;
                register[`CAUSE] = {25'b0, cause, 2'b0};
            end

            else if(eret) 
                register[`STATUS] = temp_status;
        end 
    end

    assign exc_addr = eret ? register[`EPC] : `EXCEPTION_ADDR;
    assign rdata = mfc0 ? register[addr] : 32'h0;
    assign status = register[`STATUS];

endmodule
