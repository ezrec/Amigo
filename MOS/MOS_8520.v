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

module MOS_8520 (
	inout	[7:0] PA,
	inout	[7:0] PB,
	output	_PC,
	inout	SP,
	inout	CNT,
	input	TOD,
	inout	[7:0] D,
	input	_FLAG,
	output	_IRQ,
	input	R_W,
	input	CLK_2,
	input	_CS,
	input	[3:0] RS,
	input	_RES
);

bufif1(PA[0], 1'b0, 1'b1);

endmodule
