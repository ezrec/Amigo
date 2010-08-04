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

module dff (
	input d,
	input preset,
	input clear,
	input clk,
	output q
);

reg q;

initial
	q = 0;

always @(posedge clk or posedge clear or posedge preset)
begin
	if (preset)
		#7 q <= 1;
	else if (clear)
		#7 q <= 0;
	else
		#6 q <= d;
end
endmodule

module TTL_74F74 (
	input _CD1,
	input D1,
	input CP1,
	input _SD1,
	output Q1,
	output _Q1,
	input GND,

	output _Q2,
	output Q2,
	input _SD2,
	input CP2,
	input D2,
	input _CD2,
	input VCC
);

dff dff_1 (
	.d(D1),
	.clear(!_CD1),
	.preset(!_SD1), 
	.clk(CP1),
	.q(Q1)
);
assign _Q1 = !Q1;

dff dff_2 (
	.d(D2),
	.clear(!_CD2),
	.preset(!_SD2), 
	.clk(CP2),
	.q(Q2)
);
assign _Q2 = !Q2;

endmodule
