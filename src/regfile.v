///////////////////////////////////////////////////////////////////////////////
// Author: Zirui Wu
// Type: Module
// Project: MIPS Pipeline CPU 54 Instructions
// Description: Regfile
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module regfile(
    input clk, 
    input rst, 
    input wena, 
    input [4:0] raddr1, 
    input [4:0] raddr2, 
    input rena1,
    input rena2,
    input [4:0] waddr, 
    input [31:0] wdata, 
    output reg [31:0] rdata1, 
    output reg [31:0] rdata2,
    output [31:0] reg28,
    output [31:0] reg29
    );
    
    reg [31:0] regs[0:31];
    integer i;

    // Write
	always @ (posedge clk or posedge rst) 
    begin
        if(rst == `RST_ENABLED) begin
            for(i = 0; i < 32; i = i + 1)
                regs[i] = 0; 
        end
        // If reset then read 0
	    else begin
            if((wena == `WRITE_ENABLED) && (waddr != 0))
                regs[waddr] = wdata;
        end
	end

    // Read port 1
	always @ (*) 
    begin
        // If reset then read 0
	    if(rst == `RST_ENABLED) 
			  rdata1 <= `ZERO_32BIT;

        // If read %0 register, the data will be 0
	    else if(raddr1 == 5'b0) 
	  		rdata1 <= `ZERO_32BIT;

        // When the raddr = waddr and wena = 1 and rena1 = 1, directly read the data
	    else if((raddr1 == waddr) && (wena == `WRITE_ENABLED) && (rena1 == `READ_ENABLED)) 
	  	    rdata1 <= wdata;
        
        // Read corresponding register
	    else if(rena1 == `READ_ENABLED) 
	        rdata1 <= regs[raddr1];

        // If the rena1 is disabled
	    else 
	        rdata1 <= `ZERO_32BIT;
	end

    // Read port 2
	always @ (*) 
    begin
        // If reset then read 0
	    if(rst == `RST_ENABLED) 
			  rdata2 <= `ZERO_32BIT;

        // If read %0 register, the data will be 0
	    else if(raddr2 == 5'b0) 
	  		rdata2 <= `ZERO_32BIT;
	  		
	    // When the raddr = waddr and wena = 1 and rena1 = 1, directly read the data
        else if((raddr2 == waddr) && (wena == `WRITE_ENABLED) && (rena2 == `READ_ENABLED)) 
            rdata2 <= wdata;
   
        // Read corresponding register
	    else if(rena2 == `READ_ENABLED) 
	        rdata2 <= regs[raddr2];

        // If the rena1 is disabled
	    else 
	        rdata2 <= `ZERO_32BIT;
	end

    assign reg28 = regs[28];
    assign reg29 = regs[29];

endmodule

