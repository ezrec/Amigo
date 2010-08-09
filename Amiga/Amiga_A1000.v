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

/* Amiga 1000, based off of the schematics
 */

module Amiga_A1000 (
	// Power
	input	VCC_5V,
	input	GND,

	// Keyboard
	input	KCLK,
	input	KDAT,

	// Zorro I bus (86 pin)
	input _CFGIN,	// Grounded
	output _C3,
	output CDAC,
	output _C1,
	inout	_OVR,
	inout	XRDY,
	input	_INT2,
	output	_PALOPE,
	output	[23:1] A,
	input	_INT6,
	output	[2:0] FC,
	input	_EINT7,
	input	_EINT5,
	input	_EINT4,
	input	_BERR,
	inout	_VPA,	// DO NOT USE
	output	E,
	output	_VMA,	// DO NOT USE
	inout	_RST,
	inout	_HLT,
	input	_BR,
	input	_BGACK,
	inout	[15:0] D,
	output	_BG,
	inout	_DTACK,
	output	READ,
	output	_LDS,
	output	_UDS,
	output	_AS
);


// 28.63636 Mhz clock
wire CLK_NTSC;

IO_Clock #(.clock_rate(28636360)) OSC1 (
	.CLK(CLK_NTSC)
);

wire C1R, _C1R, C2R, _C2R, C3R, _C3R, C4R, _C4R;
wire C1, C2, C3, C4, CDAC, E7M, _RAS;
wire CCK, CCKQ;
wire _C1, _C2, _C3, _C4;
wire _CLK_STG_1;
wire CLK_STG_1;

// NOTE: Skipping the XCLK/XCLKEN RGB monitor feature

TTL_74F74 U8M (
	._SD1(1'b1),
	._CD1(1'b1),
	.D1(_CLK_STG_1),
	.CP1(CLK_NTSC),
	.Q1(CLK_STG_1),
	._Q1(_CLK_STG_1),

	._SD2(1'b1),
	._CD2(_C3),
	.D2(1'b1),
	.CP2(CLK_STG_1),
	.Q2(_RAS),
	._Q2(/* Unused */)
);

TTL_74F74 U8J (
	._SD1(1'b1),
	._CD1(1'b1),
	.D1(C2R),
	.CP1(CLK_STG_1),
	.Q1(C4R),
	._Q1(_C4R),

	._SD2(1'b1),
	._CD2(1'b1),
	.D2(_C4R),
	.CP2(CLK_STG_1),
	.Q2(C2R),
	._Q2(_C2R)
);

TTL_74F74 U8K (
	._SD1(1'b1),
	._CD1(1'b1),
	.D1(C1R),
	.CP1(_CLK_STG_1),
	.Q1(C3R),
	._Q1(_C3R),

	._SD2(1'b1),
	._CD2(1'b1),
	.D2(_C4R),
	.CP2(_CLK_STG_1),
	.Q2(C1R),
	._Q2(_C1R)
);

// Ferrite beads..
assign C1 = C1R;
assign _C1 = _C1R;
assign C2 = C2R;
assign _C2 = _C2R;
assign C3 = C3R;
assign _C3 = _C3R;
assign C4 = C4R;
assign _C4 = _C4R;

assign CCK = C1R;
assign CCKQ = C3R;

// Synthesized clocks
// TODO: Use 74F351 simulation
assign E7M = C1 ^ C3;
assign CDAC = !(C1 ^ C3);

// Reset controller
// The Amiga has an analog timer, made of
// capacitors and op-amps, that checks the
// state of KCLK.
// TODO: Reset Control
// INPUT: KCLK
// OUTPUT: _HLT and _RST
pullup (weak1) (_RST);
pullup (weak1) (_HLT);

// Motorola CPU
wire _INT3;
wire [2:0] _IPL;
wire [2:0] _FC;
wire _PRW;

pullup (weak1) (_IPL[0]);
pullup (weak1) (_IPL[1]);
pullup (weak1) (_IPL[2]);
pullup (weak1) (_VPA);	// Can be driven internally or by Zorro

Motorola_68000 U6U (
	.VCC(VCC_5V),
	.GND(GND),

	.CLK(E7M),
	._RST(_RST),
	._HLT(_HLT),

	.A(A),
	._AS(_AS),
	.D(D),
	.R_W(_PRW),
	._UDS(_UDS),
	._LDS(_LDS),
	._DTACK(_DTACK),

	.E(E),
	._VMA(_VMA),
	._VPA(_VPA),

	._IPL(_IPL),
	._FC(_FC)
);

// CIA peripherials
MOS_8520 U6T (
	.PA({OVL}),
	._RES(_RST)
);

MOS_8520 U6S (
	._RES(_RST)
);

/***************** PALCAS/PALEN ***************************/

wire _ARW, _RRW;
wire _CDR, _CDW;
wire _ROME, _ROM01, _RE;
wire _RGAE, _DAE;
wire LCEN, UCEN;
wire _DBR, _BLS;
wire OVL;
wire XRDY;

wire _PALOPE;
wire PAL_ROME;

pullup (weak1) (XRDY);
pullup (weak1) (_OVR);

Amiga_PALCAS U5M (
	._ARW(_ARW),	/* Angus RW */
	.A20(A[20]),
	.A19(A[19]),
	._PRW(_PRW),	/* Processor RW */
	._UDS(_UDS),
	._LDS(_LDS),
	._ROME(PAL_ROME),
	._RE(_RE),
	._RGAE(_RGAE),
	._DAE(_DAE),
	._ROM01(/* _ROM01 */),	/* NC, due to daughterboard */
	._C1(_C1),
	._RRW(_RRW),	/* RAM Expansion RW */
	.LCEN(LCEN),
	.UCEN(UCEN),
	._CDR(_CDR),	/* Chip Ram Direction Read */
	._CDW(_CDW),	/* Chip Ram Direction Write */
	._PALOPE(_PALOPE),

	.GND(GND),
	.VCC(VCC_5V)
);

Amiga_PALEN U5L (
	.A23(A[23]),
	.A22(A[22]),
	.A21(A[21]),
	._AS(_AS),
	._DBR(_DBR),	// Goes to DAUGEN and CIA 8520 pin 25 (CLK2)
	.OVL(OVL),
	._OVR(_OVR),
	.XRDY(XRDY),
	._C3(_C3),
	._C1(_C1),
	._VPA(_VPA),
	._ROME(PAL_ROME),
	._DAE(_DAE),
	._RGAE(_RGAE),
	._RE(_RE),
	._DTACK(_DTACK),
	._BLS(_BLS),	// Goes to Angus BLS pin 

	.GND(GND),
	.VCC(VCC_5V)
);


/***************** A1000 WOM Daughterboard ****************/

wire J1;
wire J2;

pullup (strong1) (J1);
pullup (strong1) (J2);

Amiga_A1000_DAUG DAUG (
	.J1(J1),
	.J2(J2),
	.A(A),
	.D(D),
	._UDS(_UDS),
	._LDS(_LDS),
	._PRW(_PRW),	/* Processor RW */
	._DTACK(_DTACK),
	._AS(_AS),
	._DBR(_DBR),
	.OVL(OVL),
	._OVR(_OVR),
	.XRDY(XRDY),
	._C3(_C3),
	._C1(_C1),
	.C4(C4),
	._ROME(_ROME),
	._ROM01(_ROM01),
	._RAS(_RAS),
	._RST(_RST),
	.VCC(VCC_5V),
	.GND(GND)
);

/************ Paula *************/

/************ Agnus *************/
wire DMAL;
wire [7:0] RGA;
wire [7:0] DRA;
wire _VSY;
wire _CSY;
wire _HSY;
wire _LP;

Amiga_8361 U4C (
	.D(D),
	.VCC(VCC_5V),
	._RES(_RST),
	._INT3(_INT3),
	.DMAL(DMAL),
	._BLS(_BLS),
	._DBR(_DBR),	// DMA Bus Request
	._ARW(_ARW),
	.RGA(RGA),
	.CCK(CCK),
	.CCKQ(CCKQ),
	.GND(GND),
	.DRA(DRA),
	._LP(_LP),
	._VSY(_VSY),
	._CSY(_CSY),
	._HSY(_HSY)
);

endmodule
