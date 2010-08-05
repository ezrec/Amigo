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

// Helper module
module TTL_74LS244_buff (
	input	_g,
	input	a,
	output	y
);

reg y_hold;

bufif0(y, y_hold, _g);

always @(a)
	y_hold <= a;

endmodule

module TTL_74LS244 (
	input	_G1,
	input	[3:0] A1,
	output	[3:0] Y1,
	input	_G2,
	input	[3:0] A2,
	output	[3:0] Y2,

	input	VCC,
	input	GND
);

genvar i;
generate
	for (i = 0; i < 4; i = i + 1) begin: BUFF
		TTL_74LS244_buff buff1(._g(_G1),.a(A1[i]),.y(Y1[i]));
		TTL_74LS244_buff buff2(._g(_G2),.a(A2[i]),.y(Y2[i]));
	end
endgenerate

endmodule
