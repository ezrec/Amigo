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

/* Aka 'Agnus' */
module Amiga_8361 (
	inout [15:0] D,
	input VCC,
	input _RES,
	output _INT3,
	input DMAL,
	input _BLS,
	output _DBR,
	output _ARW,
	inout [7:0] RGA,
	input CCK,
	input CCKQ,
	input GND,
	output [7:0] DRA,
	input _LP,
	inout _VSY,
	output _CSY,
	inout _HSY
);

initial
	$display("TODO: Agnus");

assign _DBR = 1'b1;
assign _ARW = 1'b1;

endmodule	