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

module Amiga_PALEN (
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
	output	_VPA,	// Pin 12
	output	_ROME,	// Pin 13
	output	_DAE,	// Pin 14
	output	_RGAE,	// Pin 15
	output	_RE,	// Pin 16
	output	_DTACK,	// Pin 17
	output	_BLS,	// Pin 18
	input	VCC
);

reg VPA;
assign _VPA = !VPA;

wire AS;
assign AS = !_AS;

wire _A23;
assign _A23 = !A23;

wire _A22;
assign _A22 = !A22;

wire _A21;
assign _A21 = !A21;

reg  ROME;
assign _ROME = !ROME;

reg  RE;
assign _RE = !RE;

reg  DAE;
assign _DAE = !DAE;

reg  BLS;
assign _BLS = !BLS;

wire _OVL;
assign _OVL = !OVL;

wire DBR;
assign DBR = !_DBR;

wire C1;
wire C3;
assign C1 = !_C1;
assign C3 = !_C3;

reg DTACK;
assign _DTACK = !DTACK;

reg RGAE;
assign _RGAE = !RGAE;

// IF (/OVR) VPA = AS*A23*/A22*A21
initial VPA = 1'b0;
always @(*)
	if (_OVR == 1)
		#10 VPA <= AS && A23 && _A22 && A21;

// ROME        = AS*/DTACK*A23*A22*A21*/OVR*C1*/C3+
//                 AS*/DTACK*/A23*/A22*/A21*/OVR*OVL*C1*/C3+
//                 ROME*C1+
//                 ROME*C3
initial ROME = 1'b0;
always @(*)		// 0x000000 - 0x1fffff && 0xe00000 - 0xffffff
	#10 ROME  <= (AS && _DTACK && A23 && A22 && A21 && _OVR && C1 && _C3) ||
	             (AS && _DTACK && _A23 && _A22 && _A21 && _OVR && OVL && C1 && _C3) ||
	             (ROME && C1) || (ROME && C3);


//RE            = /DBR*AS*/DTACK*/A23*/A22*/A21*/OVL*C1*/C3*/OVR+
//                RE*C1+RE*C3
initial RE = 1'b0;
always @(*)		// 0x000000 - 0x1fffff
	#10 RE  <= (_DBR && AS && _DTACK && _A23 && _A22 && _A21 && _OVL && C1 && _C3 && _OVR) ||
	    (RE && C1) || (RE && C3);

// IF (/OVR) DTACK = AS*/A23*/A22*A21*XRDY+
//                   AS*/A23*A22*XRDY+
//                   AS*A23*/A22*/A21*XRDY+
//                   ROME*XRDY*C3+
//                   RE*C3+RGAE*C3+DTACK*AS*XRDY
initial DTACK = 1'b0;
always @(*)
	if (_OVR == 1)
		#10 DTACK <= (AS && _A23 && _A22 && A21 && XRDY) ||	// 0x200000 - 0x3ffffff
			     (AS && _A23 && A22 && XRDY) ||		// 0x400000 - 0x7ffffff
			     (AS && A23 && _A22 && _A21 && XRDY) ||	// 0x800000 - 0x9ffffff
			     (ROME && XRDY && C3) ||
			     (RE && C3) || (RGAE && C3) ||
			     (DTACK && AS && XRDY);
	     
//RGAE          = /DBR*AS*/DTACK*A23*A22*/A21*C1*/C3*/OVR+
//                RGAE*C1+RGAE*C3
initial RGAE = 1'b0;
always @(*)		// 0xc00000 - 0xdfffff
	#10 RGAE  <= (_DBR && AS && _DTACK && A23 && A22 && _A21 && C1 && _C3 && _OVR) ||
	      (RGAE && C1) || (RGAE && C3);

//DAE           = DBR*C1*/C3+
//                DAE*C1+DAE*C3
initial DAE = 1'b0;
always @(*)
	#10 DAE  <= (DBR && C1 && _C3) ||
	     (DAE && C1) || (DAE && C3);

//Blitter Slowdown
//BLS           = AS*/DTACK*/A23*/A22*/A21*/OVL*C1*/C3*/OVR+
//                AS*/DTACK*A23*A22*/A21*C1*/C3*/OVR+
//                BLS*C1+BLS*C3
initial BLS = 1'b0;
always @(*)		// 0x000000 - 0x1fffff && 0xc00000 - 0xdfffff
	#10 BLS  <= (AS && _DTACK && _A23 && _A22 && _A21 && _OVL && C1 && _C3 && _OVR) ||
	     (AS && _DTACK && A23 && A22 && _A21 && C1 && _C3 && _OVR) ||
	     (BLS && C1) || (BLS && C3);

endmodule
