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

module TTL_74LS393 (
	input	_A1,
	input	R1,
	output	[3:0] O1,

	input	_A2,
	input	R2,
	output	[3:0] O2,

	input	VCC,
	input	GND
);

TTL_74LS93 cnt1 (
	._A(_A1),
	.R(R1),
	.O(O1),
	.VCC(VCC),
	.GND(GND)
);

TTL_74LS93 cnt2 (
	._A(_A2),
	.R(R2),
	.O(O2),
	.VCC(VCC),
	.GND(GND)
);

endmodule
