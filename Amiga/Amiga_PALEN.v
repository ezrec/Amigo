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
	input	_VPA,
	output	_ROME,
	output	_DAE,
	output	_RGAE,
	output	_RE,
	output	_DTACK,
	output	_BLS,
	input	VCC
);

wire VPA;
assign VPA = !_VPA;

wire AS;
assign AS = !_AS;

wire _A23;
assign _A23 = !A23;

wire _A22;
assign _A22 = !A22;

wire _A21;
assign _A21 = !A21;

wire ROME;
assign _ROME = !ROME;

wire RE;
assign _RE = !RE;

wire DAE;
assign _DAE = !DAE;

wire BLS;
assign _BLS = !BLS;

wire _OVL;
assign _OVL = !OVL;

wire DBR;
assign DBR = !_DBR;

wire C1;
wire C3;
assign C1 = !_C1;
assign C3 = !_C3;

wire DTACK;
assign _DTACK = !DTACK;

wire RGAE;
assign _RGAE = !RGAE;

// IF (/OVR) VPA = AS*A23*/A22*A21
bufif1(VPA, AS && A23 && _A22 && A21, _OVR);

// ROME        = AS*/DTACK*A23*A22*A21*/OVR*C1*/C3+
//                 AS*/DTACK*/A23*/A22*/A21*/OVR*OVL*C1*/C3+
//                 ROME*C1+
//                 ROME*C3
assign ROME = (AS && _DTACK && A23 && A22 && A21 && _OVR && C1 && _C3) ||
	      (AS && _DTACK && _A23 && _A22 && _A21 && _OVR && C1 && _C3) ||
	      (ROME && C1) || (ROME && C3);

//RE            = /DBR*AS*/DTACK*/A23*/A22*/A21*/OVL*C1*/C3*/OVR+
//                RE*C1+RE*C3
assign RE = (_DBR && AS && _DTACK && _A23 && _A22 && _A21 && _OVL && C1 && _C3 && _OVR) ||
	    (RE && C1) || (RE && C3);

// IF (/OVR) DTACK = AS*/A23*/A22*A21*XRDY+
//                   AS*/A23*A22*XRDY+
//                   AS*A23*/A22*/A21*XRDY+
//                   ROME*XRDY*C3+
//                   RE*C3+RGAE*C3+DTACK*AS*XRDY
bufif1(DTACK, (AS && _A23 && _A22 && A21 && XRDY) ||
	      (AS && _A23 && A22 && XRDY) ||
	      (AS && A23 && _A22 && _A21 && XRDY) ||
	      (ROME && XRDY && C3) ||
      	      (RE && C3) || (RGAE && C3) ||
      	      (DTACK && AS && XRDY),
       _OVR);
	     
//RGAE          = /DBR*AS*/DTACK*A23*A22*/A21*C1*/C3*/OVR+
//                RGAE*C1+RGAE*C3
assign RGAE = (_DBR && AS && _DTACK && A23 && A22 && _A21 && C1 && _C3 && _OVR) ||
	      (RGAE && C1) || (RGAE && C3);

//DAE           = DBR*C1*/C3+
//                DAE*C1+DAE*C3
assign DAE = (DBR && C1 && _C3) ||
	     (DAE && C1) || (DAE && C3);

//BLS           = AS*/DTACK*/A23*/A22*/A21*/OVL*C1*/C3*/OVR+
//                AS*/DTACK*A23*A22*/A21*C1*/C3*/OVR+
//                BLS*C1+BLS*C3
assign BLS = (AS && _DTACK && _A23 && _A22 && _A21 && _OVL && C1 && _C3 && _OVR) ||
	     (AS && _DTACK && A23 && A22 && _A21 && C1 && _C3 && _OVR) ||
	     (BLS && C1) || (BLS && C3);

endmodule
