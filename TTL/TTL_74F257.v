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

module TTL_74F257 (
	input	S,
	input	I0a,
	input	I1a,
	output	Za,
	input	I0b,
	input	I1b,
	output	Zb,
	input	GND,
	output	Zd,
	input	I1d,
	input	I0d,
	output	Zc,
	input	I1c,
	input	I0c,
	input	_OE,
	input	VCC
);

wire Ia;
assign Ia = (I0a && !S) || (I1a && S);
bufif0(Za, Ia, _OE);

wire Ib;
assign Ib = (I0b && !S) || (I1b && S);
bufif0(Zb, Ib, _OE);

wire Ic;
assign Ia = (I0c && !S) || (I1c && S);
bufif0(Zc, Ic, _OE);

wire Id;
assign Id = (I0d && !S) || (I1d && S);
bufif0(Zd, Id, _OE);

endmodule
