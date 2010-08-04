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

module Amiga_DAUGCAS (
	input	_SROM,
	input	A18,
	input	A17,
	input	_PRW,
	input	_UDS,
	input	_LDS,
	input	_RE,
	input	_RES,
	input	_ROME,
	input	GND,
	input	_C1,
	input	_BERR,
	output	_WPRO,
	output	_RRW,
	output	_LCEN,
	output	_UCEN,
	output	_CDR,
	output	_CDW,
	output	_ROM01,
	input	VCC
);

wire SROM;
wire _A18;
wire _A17;
wire PRW;
wire UDS;
wire LDS;
wire RE;
wire RES;
wire ROME;
wire C1;
wire BERR;
wire WPRO;
wire RRW;
wire LCEN;
wire UCEN;
wire CDR;
wire CDW;
wire ROM01;


// Inputs
assign SROM = !_SROM;
assign _A18 = !A18;
assign _A17 = !A17;
assign PRW = !_PRW;
assign UDS = !_UDS;
assign LDS = !_LDS;
assign RE = !_RE;
assign RES = !_RES;
assign ROME = !_ROME;
assign C1 = !_C1;
assign BERR = !_BERR;
// Outputs
assign _WPRO = !WPRO;
assign _RRW = !RRW;
assign _LCEN = !LCEN;
assign _UCEN = !UCEN;
assign _CDR = !CDR;
assign _CDW = !CDW;
assign _ROM01 = !ROM01;

// ROM01 = ROME*/A17*/WPRO*/SROM*/PRW
assign ROM01 = ROME && _A17 &&  _WPRO && _SROM && _PRW;

// CDR   = CDR*LDS+CDR*UDS+RE*/PRW*/C1*A18+RE*/PRW*/C1*/A18*WPRO+
//        RE*/PRW*/C1/A18*SROM
assign CDR = (CDR && LDS) ||
	     (CDR && UDS) ||
	     (RE && _PRW && _C1 && A18) ||
	     (RE && _PRW && _C1 && _A18 && WPRO);

// CDW   = RE*PRW+CDW*/C1
assign CDW = (RE && PRW) || (CDW && _C1);

// UCEN  = UCEN*/C1+RE*UDS*A18+RE*UDS*/A18*WPRO+
//         RE*UDS*/A18*SROM
assign UCEN = (UCEN && _C1) ||
	      (RE && UDS && A18) ||
	      (RE && UDS && _A18 && WPRO) ||
	      (RE && UDS && _A18 && SROM);

// LCEN  = LCEN*/C1+RE*LDS*A18+RE*LDS*/A18*WPRO+
//         RE*LDS*/A18*SROM
assign LCEN = (LCEN && _C1) ||
	      (RE && LDS && A18) ||
	      (RE && LDS && _A18 && WPRO) ||
	      (RE && LDS && _A18 && SROM);

// RRW   = RE*PRW*A18*/WPRO*/SROM
assign RRW = (RE && PRW && A18 && _WPRO && _SROM);

// BERR  = WPRO*PRW*RE
assign BERR = (WPRO && PRW && RE);

// WPRO  = WPRO*/RES+PRW*RE*/A18
assign WPRO = (WPRO && _RES) ||
	      (PRW && RE && _A18);


endmodule
