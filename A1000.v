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

module A1000 (
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
	input	_OVR,
	input	RDY,
	input	_INT2,
	output	_PALOPE,
	output	[23:1] A,
	input	_INT6,
	output	[2:0] FC,
	input	_EINT7,
	input	_EINT5,
	input	_EINT4,
	input	_BERR,
	input	_VPA,	// DO NOT USE
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

wire [2:0] _IPL;

pullup (weak1) (_IPL[0]);
pullup (weak1) (_IPL[1]);
pullup (weak1) (_IPL[2]);
pullup (weak1) (_DTACK);
wire [2:0] _FC;
wire R_W;

Motorola_68000 U6U (
	.VCC(VCC_5V),
	.GND(GND),

	.CLK(E7M),
	._RST(_RST),
	._HLT(_HLT),

	.A(A),
	._AS(_AS),
	.D(D),
	.R_W(R_W),
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

wire _ARW, _PRW, _RRW;
wire _CDR, _CDW;
wire _ROME, _ROM01, _RE;
wire _RGAE, _DAE;
wire LCEN, UCEN;
wire _DBR, _BLS;
wire OVL;
wire XRDY;

Amiga_PALCAS U6P (
	._ARW(_ARW),	/* Angus RW */
	.A20(A[20]),
	.A19(A[19]),
	._PRW(_PRW),	/* Paula RW */
	._UDS(_UDS),
	._LDS(_LDS),
	._ROME(_ROME),
	._RE(_RE),
	._RGAE(_RGAE),
	._DAE(_DAE),
	._ROM01(/* NC */),	/* NC, due to daughterboard */
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

Amiga_PALEN U4T (
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
	._ROME(_ROME),
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

assign J1 = 1'b1;

wire DAUG_RE;
wire DAUG_UCEN;
wire DAUG_LCEN;
wire DAUG_RRW;
wire DAUG_DAE;	// NOTE: Unneeded inverter U1S/pins 1,2,3 was stripped
wire DAUG_ONT;
wire [7:0] DAUG_A;
wire [15:0] DAUG_D;

wire DAUG_LED_WPRO;

IO_LED LEDL (
	._I(DAUG_LED_WPRO)
);

// Daughterboard CAS
Amiga_DAUGCAS U6N (
	._SROM(J1),
	._C1(_C1),
	.A17(A[17]),
	.A18(A[18]),
	._UDS(_UDS),
	._LDS(_LDS),
	._PRW(_PRW),
	._UCEN(DAUG_UCEN),
	._LCEN(DAUG_LCEN),
	._RRW(DAUG_RRW),
	._RE(DAUG_RE),
	._ROM01(_ROM01),
	._ROME(_ROME),
	._WPRO(DAUG_LED_WPRO),
	._RES(_RST)
);

wire A16_DELAYED;

// Daughterboard Enable
Amiga_DAUGEN U4S (
	.A19(A[19]),
	.A20(A[20]),
	.A21(A[21]),
	.A22(A[22]),
	.A23(A[23]),
	._AS(_AS),
	._DBR(_DBR),
	._DAE(DAUG_DAE),
	._ONT(DAUG_ONT),
	.OVL(OVL),
	._OVR(_OVR),
	.XRDY(XRDY),
	._C3(_C3),
	._C1(_C1),
	._DTACK(_DTACK),
	._RE(DAUG_RE),
	._ROME(_ROME)
);

wire J2;

// Forced pull-up by R118
assign J2 = 1'b1;

wire A17_SEL;
wire _A16_A17_SEL;
wire A16_A17_SEL;
TTL_74F02 U1S (
	.A1(J2),
	.B1(A[17]),
	.Q1(A17_SEL),
	.A3(A[16]),
	.B3(A17_SEL),
	.Q3(_A16_A17_SEL),
	.A2(_A16_A17_SEL),
	.B2(_A16_A17_SEL),
	.Q2(A16_A17_SEL)
);


// Daughterboard address selects
TTL_74F257 U3R (
	.I1c(A16_A17_SEL),
	.I1d(A[19]),
	.I1a(A[11]),
	.I1b(A[9]),
	.I0c(A[8]),
	.I0d(A[6]),
	.I0a(A[3]),
	.I0b(A[1]),
	.Zc(DAUG_A[7]),
	.Zd(DAUG_A[5]),
	.Za(DAUG_A[2]),
	.Zb(DAUG_A[0]),
	._OE(DAUG_RE),
	.S(C4)
);

TTL_74F257 U3S (
	.I1c(A[15]),
	.I1d(A[13]),
	.I1a(A[12]),
	.I1b(A[10]),
	.I0c(A[7]),
	.I0d(A[5]),
	.I0a(A[4]),
	.I0b(A[2]),
	.Zc(DAUG_A[6]),
	.Zd(DAUG_A[4]),
	.Za(DAUG_A[3]),
	.Zb(DAUG_A[1]),
	._OE(DAUG_RE),
	.S(C4)
);

wire UxJ_CAS;
wire UxK_CAS;
wire UxL_CAS;
wire UxM_CAS;

TTL_74F139 U1R (
	.A1b(A[17]),
	.A0b(_C1),
	._Eb(DAUG_UCEN),
	._O3b(UxM_CAS),
	._O1b(UxL_CAS),
	.A1a(A[17]),
	.A0a(_C1),
	._Ea(DAUG_LCEN),
	._O3a(UxK_CAS),
	._O1a(UxJ_CAS)
);

RAM_41464 U2J (
	._CAS(UxJ_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[0]),
	.DQ1(DAUG_D[1]),
	.DQ3(DAUG_D[2]),
	.DQ4(DAUG_D[3]),
	._OE(1'b0)
);

RAM_41464 U2K (
	._CAS(UxK_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[0]),
	.DQ1(DAUG_D[1]),
	.DQ3(DAUG_D[2]),
	.DQ4(DAUG_D[3]),
	._OE(1'b0)
);

RAM_41464 U1J (
	._CAS(UxJ_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[4]),
	.DQ1(DAUG_D[5]),
	.DQ3(DAUG_D[6]),
	.DQ4(DAUG_D[7]),
	._OE(1'b0)
);

RAM_41464 U1K (
	._CAS(UxK_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[4]),
	.DQ1(DAUG_D[5]),
	.DQ3(DAUG_D[6]),
	.DQ4(DAUG_D[7]),
	._OE(1'b0)
);

RAM_41464 U2L (
	._CAS(UxL_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[8]),
	.DQ1(DAUG_D[9]),
	.DQ3(DAUG_D[10]),
	.DQ4(DAUG_D[11]),
	._OE(1'b0)
);

RAM_41464 U2M (
	._CAS(UxM_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[8]),
	.DQ1(DAUG_D[9]),
	.DQ3(DAUG_D[10]),
	.DQ4(DAUG_D[11]),
	._OE(1'b0)
);

RAM_41464 U1L (
	._CAS(UxL_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[12]),
	.DQ1(DAUG_D[13]),
	.DQ3(DAUG_D[14]),
	.DQ4(DAUG_D[15]),
	._OE(1'b0)
);

RAM_41464 U1M (
	._CAS(UxM_CAS),
	.A6(DAUG_A[7]),
	.A5(DAUG_A[6]),
	.A4(DAUG_A[5]),
	.A7(DAUG_A[4]),
	.A3(DAUG_A[3]),
	.A2(DAUG_A[2]),
	.A1(DAUG_A[1]),
	.A0(DAUG_A[0]),
	._W(DAUG_RRW),
	._RAS(_RAS),
	.DQ2(DAUG_D[12]),
	.DQ1(DAUG_D[13]),
	.DQ3(DAUG_D[14]),
	.DQ4(DAUG_D[15]),
	._OE(1'b0)
);

endmodule

