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

module TTL_74F139 (
	input	_Ea,
	input	A0a,
	input	A1a,
	output	_O0a,
	output	_O1a,
	output	_O2a,
	output	_O3a,
	input	GND,
	output	_O3b,
	output	_O2b,
	output	_O1b,
	output	_O0b,
	input	A1b,
	input	A0b,
	input	_Eb,
	input	VCC
);

wire [3:0] Oa;
wire [1:0] Aa;

assign Aa = { A1a, A0a };
assign Oa = 4'he << Aa;

bufif0(_O0a, Oa[0], _Ea);
bufif0(_O1a, Oa[1], _Ea);
bufif0(_O2a, Oa[2], _Ea);
bufif0(_O3a, Oa[3], _Ea);

wire [3:0] Ob;
wire [1:0] Ab;

assign Ab = { A1b, A0b };
assign Ob = 4'he << Ab;

bufif0(_O0b, Ob[0], _Eb);
bufif0(_O1b, Ob[1], _Eb);
bufif0(_O2b, Ob[2], _Eb);
bufif0(_O3b, Ob[3], _Eb);

endmodule
