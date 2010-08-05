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

// Replicated component
module TTL_74LS373_DFF (
	input	d,
	input	_oe,
	input	le,
	output	o
);

reg o_hold;

bufif0(o, o_hold, _oe);

always @(d)
	if (le)
		#10 o_hold <= d;

endmodule

module TTL_74LS373 (
	input	_OE,
	output	[7:0]	O,
	input	[7:0]	I,
	input	LE,

	input	VCC,
	input	GND
);

genvar i;
generate 
	for (i = 0; i < 8; i = i + 1) begin: DFF
		TTL_74LS373_DFF dff(.d(I[i]),._oe(_OE),.le(LE),.o(O[i]));
	end
endgenerate

endmodule
