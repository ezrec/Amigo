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

module TTL_74LS93_toggle (
	input	_t,
	input	_r,
	output	o
);

reg o;

always @(negedge _r or negedge _t)
	if (_r == 0)
		o <= 1'b0;
	else if (_t == 0) begin
		if (o == 1'b0)
			o <= 1'b1;
		else
			o <= 1'b0;
	end

endmodule

module TTL_74LS93 (
	input	_A,
	input	R,
	output	[3:0] O,

	input	VCC,
	input	GND
);

TTL_74LS93_toggle tA(._t(_A),._r(!R),.o(O[0]));
TTL_74LS93_toggle tB(._t(O[0]),._r(!R),.o(O[1]));
TTL_74LS93_toggle tC(._t(O[1]),._r(!R),.o(O[2]));
TTL_74LS93_toggle tD(._t(O[2]),._r(!R),.o(O[3]));

endmodule
