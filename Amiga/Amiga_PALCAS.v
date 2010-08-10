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

module Amiga_PALCAS (
	input GND,
	input VCC,

	input _ARW,
	input A20,
	input A19,
	input _PRW,
	input _UDS,
	input _LDS,
	input _ROME,
	input _RE,
	input _RGAE,
	input _DAE,
	output _ROM01,
	input _C1,
	output _RRW,
	output LCEN,
	output UCEN,
	output _CDR,
	output _CDW,
	output _PALOPE
);

assign _PALOPE = 1'b1;

wire ROME;
reg  ROM01;
reg  CDR;
reg  CDW;
wire RE;
wire RGAE;
wire UDS;
wire LDS;
wire C1;
reg  RRW;
wire PRW;
wire ARW;
wire DAE;
wire _A20;
wire _A19;
reg  _UCEN;
reg  _LCEN;

assign RE = !_RE;
assign ROME = !_ROME;
assign RGAE = !_RGAE;
assign UDS = !_UDS;
assign LDS = !_LDS;
assign C1 = !_C1;
assign PRW = !_PRW;
assign ARW = !_ARW;
assign DAE = !_DAE;
assign _A20 = !A20;
assign _A19 = !A19;
assign _ROM01 = !ROM01;
assign _CDR = !CDR;
assign _CDW = !CDW;
assign _RRW = !RRW;
assign UCEN = !_UCEN;
assign LCEN = !_LCEN;

// ROM01 = ROME*A20*A19*/PRW+ROME*/A20*/A19*/PRW
initial ROM01 = 1'b0;
always @(*)	// ROME | 0x180000 - 0x1fffff, ROME | 0x000000 - 0x07ffff
	ROM01  <= (ROME && A20 && A19 && _PRW) ||
	       (ROME && _A20 && _A19 && _PRW);

// CDR   = RE*/PWR*/C1+RGAE*/PRW*/C1+CDR*LDS+CDR*UDS
initial CDR = 1'b0;
always @(*)
	CDR  <= (RE && _PRW && _C1) ||
	     (RGAE && _PRW && _C1) ||
	     (CDR && LDS) ||
	     (CDR && UDS);

// CDW   = RE*PRW+RGAE*PRW+CDW*/C1+/DAE*/UDS*/UCEN
initial CDW = 1'b0;
always @(*)
	CDW  <= (RE && PRW) ||
             (RGAE && PRW) ||
             (CDW && _C1) ||
             (_DAE && _UDS && _UCEN);

// /UCEN = /DAE*/RE*/UCEN+/DAE*/RE*C1+/DAE*/UDS*C1+/DAE*/UDS*/UCEN
initial _UCEN = 1'b1;
always @(*)
	_UCEN  <= (_DAE && _RE && _UCEN) ||
	       (_DAE && _RE && C1) ||
	       (_DAE && _UDS && C1) ||
	       (_DAE && _UDS && _UCEN);
// /LCEN = /DAE*/RE*/LCEN+/DAE*/RE*C1+/DAE*/LDS*C1+/DAE*/LDS*/LCEN
initial _LCEN = 1'b1;
always @(*)
	_LCEN  <= (_DAE && _RE && _LCEN) ||
	       (_DAE && _RE && C1) ||
	       (_DAE && _LDS && C1) ||
	       (_DAE && _LDS && _LCEN);

// RRW   = RE*PRW+DAE*ARW*C1+RRW*DAE
initial RRW = 1'b0;
always @(*)
	RRW  <= (RE && PRW) ||
	     (DAE && ARW && C1) ||
	     (RRW && DAE);

endmodule
