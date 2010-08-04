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

module TTL_74F02 (
	input	A0,
	input	B0,
	output	Q0,
	input	A1,
	input	B1,
	output	Q1,
	input	A2,
	input	B2,
	output	Q2,
	input	A3,
	input	B3,
	output	Q3
);

assign Q0 = !(A0 || B0);
assign Q1 = !(A1 || B1);
assign Q2 = !(A2 || B2);
assign Q3 = !(A3 || B3);

endmodule
