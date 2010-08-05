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
	input	A23,	// Pin 1
	input	A22,	// Pin 2
	input	A21,	// Pin 3
	input	_AS,	// Pin 4
	input	_DBR,	// Pin 5
	input	OVL,	// Pin 6
	input	_OVR,	// Pin 7
	input	XRDY,	// Pin 8
	input	_C3,	// Pin 9
	input	GND,	// Pin 10
	input	_C1,	// Pin 11
	output	_CNT,	// Pin 12
	output	_RE,	// Pin 13
	output	_DAE,	// Pin 14
	output	_NC1,	// Pin 15
	input	A19,	// Pin 16
	input	_DTACK,	// Pin 17
	input	A20,	// Pin 18
	output	_ROME,	// Pin 19
	input	VCC	// Pin 20
);

wire _A23;
wire _A22;
wire _A21;
wire _A20;
wire _A19;
wire AS;
wire C1;
wire C3;

reg RE;
reg ROME;
reg _DAE;
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
assign _ROME = !ROME;
assign DAE = _DAE;
reg _CNT;

// /CNT  = DAE*C1*C3
initial _CNT = 1'b1;
always @(*)
	_CNT <= DAE && C1 && C3;

// RE    = AS*/DTACK*A23*A22*A21*A20*A19*/OVR*C1*/C3+
//         AS*/DTACK*/A23*/A22*/A21*/A20*/A19*/OVR*OVL*C1*/C3+
//         RE*C1+RE*C3
initial RE = 1'b0;
always @(*)
	RE <= (AS && _DTACK && A23 && A22 && A21 && A20 && A19 && _OVR && C1 && _C3) ||
	    (AS && _DTACK && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && C1 && _C3) ||
	    (RE && C1) ||
	    (RE && C3);

// /DAE  = /C1*/C3+RE+
//        AS*/DTACK*A23*A22*A21*A20*A19*/OVR*OVL*C1*/C3+
//        AS*/DTACK*/A23*/A22*/A21*/A20*/A19*/OVR*OVL*C1*/C3
initial _DAE = 1'b1;
always @(*)
	_DAE <= (_C1 && _C3) ||
	      (RE) ||
	      (AS && _DTACK && A23 && A22 && A21 && A20 && A19 && _OVR && OVL && C1 && _C3) ||
	      (AS && _DTACK && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && OVL && C1 && _C3);

// ROME  = AS*A23*A22*A21*A20*A19*/OVR+
//         AS*/A23*/A22*/A21*/A20*/A19*/OVR*OVL
initial ROME = 1'b0;
always @(*)
	ROME <= (AS && A23 && A22 && A21 && A20 && A19 && _OVR) ||
	        (AS && _A23 && _A22 && _A21 && _A20 && _A19 && _OVR && OVL);

endmodule
