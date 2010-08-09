/*
 * Copyright (C) 2010, Jason S. McMullan. All rights reserved.
 * Author: Jason S. McMullan <jason.mcmullan@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

`timescale 1ns/1ps

/* 64K NEC 41464 DRAM
 */

module RAM_41464 (
	input	_OE,		// Pin 1
	inout	[3:0] DQ,	// Pin 17,15,3,2
	input	_WE,		// Pin 3
	input	_RAS,		// Pin 5
	input	[7:0] A,	// Pin 10,6,7,8,11,12,13,14
	input	VCC,		// Pin 9
	input	_CAS,		// Pin 16
	input	GND		// Pin 18
);

reg [7:0] row;
reg [7:0] col;
reg [3:0] ram [0:65536];
reg [3:0] DQ_o;

integer c;

initial begin
	for (c = 0; c < 65536; c = c + 1)
		ram[c] = 4'b1001;
end

// If _CAS == 1, then DQ must be high impedenace
genvar i;
generate
	for (i = 0; i < 4; i = i + 1) begin: DQ_OE
		bufif1(DQ[i], DQ_o[i], _WE && !_OE && !_CAS);
	end
endgenerate

always @(GND or VCC) 
	if (VCC == 1'b1 && GND == 1'b0) begin
	end

always @(negedge _RAS)
	row <= A;

always @(negedge _CAS)
	if (_CAS == 1'b0) begin
		col <= A;
		DQ_o <= ram[{row,col}];
	end

always @(negedge _CAS or negedge _WE)
	if (_WE == 1'b0 && _CAS == 1'b0)
		ram[{row,col}] <= DQ;

always @(negedge _CAS or negedge _OE)
	if (_CAS == 1'b0 && _CAS == 1'b0)
		DQ_o <= ram[{row,col}];


endmodule
