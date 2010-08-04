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

module Amiga_DAUGEN (
	input	A23,
	input	A22,
	input	A21,
	input	_AS,
	input	_DBR,
	input	OVL,
	input	_OVR,
	input	XRDY,
	input	_C3,
	input	GND,
	input	_C1,
	output	_ONT,
	output	_RE,
	output	_DAE,
	output	_NC1,
	input	A19,
	input	_DTACK,
	input	A20,
	output	_ROME,
	input	VCC
);

wire _A23;
wire _A22;
wire _A21;
wire _A20;
wire _A19;
wire AS;
wire C1;
wire C3;

wire RE;
wire ROME;
wire DAE;

assign _A23 = A23;
assign _A22 = A22;
assign _A21 = A21;
assign _A20 = A20;
assign _A19 = A19;
assign AS = _AS;
assign C3 = _C3;
assign C1 = _C1;

assign _RE = RE;
assign _ROME = ROME;
assign DAE = _DAE;

// /ONT  = DAE*C1*C3
assign _ONT = DAE && C1 && C3;

// RE    = AS*/DTACK*A23*A22*A21*A20*A19*/OVR*C1*/C3+
//         AS*/DTACK*/A23*/A22*/A21*/A20*/A19*/OVR*OVL*C1*/C3+
//         RE*C1+RE*C3
assign RE = (AS && _DTACK && A23 && A22 && A21 && A20 && A19 && _OVR && C1 && _C3) ||
	    (AS && _DTACK && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && C1 && _C3) ||
	    (RE && C1) ||
	    (RE && C3);

// /DAE  = /C1*/C3+RE+
//        AS*/DTACK*A23*A22*A21*A20*A19*/OVR*OVL*C1*/C3+
//        AS*/DTACK*/A23*/A22*/A21*/A20*/A19*/OVR*OVL*C1*/C3
assign _DAE = (_C1 && _C3) ||
	      (RE) ||
	      (AS && _DTACK && A23 && A22 && A21 && A20 && A19 && _OVR && OVL && C1 && _C3) ||
	      (AS && _DTACK && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && OVL && C1 && _C3);

//ROME  = AS*A23*A22*A21*A20*A19*/OVR+
//        AS*/A23*/A22*/A21*/A20*/A19*/OVR*OVL
assign ROME = (AS && A23 && A22 && A21 && A20 && A19 && _OVR) ||
	      (AS && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && OVL);

endmodule
