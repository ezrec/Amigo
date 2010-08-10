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

module Amiga_A1000_DAUG (
	input	J1_ENABLE,
	input	J2_ENABLE,
	input	[23:1] A,
	inout	[15:0] D,
	input	_LDS,
	input	_UDS,
	input	_PRW,
	inout	_DTACK,
	input	_AS,
	input	_DBR,
	input	OVL,
	input	_OVR,
	input	XRDY,
	input	_C3,
	input	_C1,
	input	C4,
	output	_ROME,
	output	_ROM01,
	input	_RAS,
	input	_RST,

	input	VCC,
	input	GND
);

wire _CDW;
wire _CDR;
wire DAUG_RE;
wire DAUG_UCEN;
wire DAUG_LCEN;
wire DAUG_RRW;
wire DAUG_DAE;	// NOTE: Unneeded inverter U1S/pins 1,2,3 was stripped
wire DAUG_CNT;
wire [7:0] DAUG_A;
wire [15:0] DAUG_D;

wire DAUG_LED_WPRO;
wire DAUG_LED_WPRO_c;

Resistor_Limiting #(.ohms(220), .volts(5.0)) R94 (
	.I(DAUG_LED_WPRO),
	.O(DAUG_LED_WPRO_c)
);

LED #(.name("WPRO")) LEDL (
	._I(DAUG_LED_WPRO_c)
);

wire J1_SEL;

Resistor_Pullup #(.ohms(1000), .volts(5.0)) R93 (
	.VCC(VCC),
	.O(J1_SEL)
);

Jumper_Ground J1 (
	.GND(GND),
	.O(J1_SEL),
	.ENABLE(J1_ENABLE)
);

wire J2_SEL;

Resistor_Pullup #(.ohms(1000), .volts(5.0)) R118 (
	.VCC(VCC),
	.O(J2_SEL)
);

Jumper_Ground J2 (
	.GND(GND),
	.O(J2_SEL),
	.ENABLE(J2_ENABLE)
);



// Daughterboard CAS
Amiga_DAUGCAS U6N (
	._SROM(J1_SEL),
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
	._CDR(_CDR),
	._CDW(_CDW),
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
	._CNT(DAUG_CNT),
	.OVL(OVL),
	._OVR(_OVR),
	.XRDY(XRDY),
	._C3(_C3),
	._C1(_C1),
	._DTACK(_DTACK),
	._RE(DAUG_RE),
	._ROME(_ROME)
);

wire A17_SEL;
wire _A16_A17_SEL;
wire A16_A17_SEL;
TTL_74F02 U1S (
	.A1(J2_SEL),
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
	.I1d(A[14]),
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

TTL_74LS373 U4J (
	.O(D[15:8]),
	.I(DAUG_D[15:8]),
	.LE(C4),
	._OE(_CDR)
);

TTL_74LS373 U3J (
	.O(D[7:0]),
	.I(DAUG_D[7:0]),
	.LE(C4),
	._OE(_CDR),

	.VCC(VCC),
	.GND(GND)
);

TTL_74LS244 U4K (
	._G1(_CDW),
	.A1({D[14],D[13],D[11],D[9]}),
	.Y1({DAUG_D[14],DAUG_D[13],DAUG_D[11],DAUG_D[9]}),

	._G2(_CDW),
	.A2({D[15],D[12],D[10],D[8]}),
	.Y2({DAUG_D[15],DAUG_D[12],DAUG_D[10],DAUG_D[8]}),

	.VCC(VCC),
	.GND(GND)
);


TTL_74LS244 U3K (
	._G1(DAUG_RE),
	.A1({D[7],D[5],D[3],D[1]}),
	.Y1({DAUG_D[7],DAUG_D[5],DAUG_D[3],DAUG_D[1]}),

	._G2(DAUG_RE),
	.A2({D[6],D[4],D[2],D[0]}),
	.Y2({DAUG_D[6],DAUG_D[4],DAUG_D[2],DAUG_D[0]}),

	.VCC(VCC),
	.GND(GND)
);

wire [7:0] STROBE_A;

// Row strobe generation
TTL_74LS393 U2T (
	._A1(DAUG_CNT),
	.O1(STROBE_A[3:0]),
	.R1(GND),
	
	._A2(STROBE_A[3]),
	.O2(STROBE_A[7:4]),
	.R2(GND),

	.VCC(VCC),
	.GND(GND)
);

// Buffer the strobe
TTL_74LS244 U3T (
	._G1(DAUG_DAE),
	.A1(STROBE_A[3:0]),
	.Y1(DAUG_A[3:0]),

	._G2(DAUG_DAE),
	.A2(STROBE_A[7:4]),
	.Y2(DAUG_A[7:4]),

	.VCC(VCC),
	.GND(GND)
);

wire UxJ_CAS;
wire UxK_CAS;
wire UxL_CAS;
wire UxM_CAS;
wire UxJ_CAS_d;
wire UxK_CAS_d;
wire UxL_CAS_d;
wire UxM_CAS_d;

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

Resistor_Damping #(.ohms(39)) R122 (.I(UxJ_CAS),.O(UxJ_CAS_d));
Resistor_Damping #(.ohms(39)) R121 (.I(UxK_CAS),.O(UxK_CAS_d));
Resistor_Damping #(.ohms(39)) R120 (.I(UxL_CAS),.O(UxL_CAS_d));
Resistor_Damping #(.ohms(39)) R119 (.I(UxM_CAS),.O(UxM_CAS_d));

wire DAUG_RRW_d;
wire _RAS_d;
 
Resistor_Damping #(.ohms(39)) R123 (.I(DAUG_RRW),.O(DAUG_RRW_d));
Resistor_Damping #(.ohms(39)) R124 (.I(_RAS),.O(_RAS_d));

RAM_41464 U2J (
	._CAS(UxJ_CAS_d),
	.A({
	    DAUG_A[4],
	    DAUG_A[7],
	    DAUG_A[6],
	    DAUG_A[5],
	    DAUG_A[3],
	    DAUG_A[2],
	    DAUG_A[1],
	    DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[0],
	     DAUG_D[1],
	     DAUG_D[2],
	     DAUG_D[3]
	}),
	._OE(1'b0)
);

RAM_41464 U2K (
	._CAS(UxK_CAS_d),
	.A({
	    DAUG_A[4],
	    DAUG_A[7],
	    DAUG_A[6],
	    DAUG_A[5],
	    DAUG_A[3],
	    DAUG_A[2],
	    DAUG_A[1],
	    DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[0],
	     DAUG_D[1],
	     DAUG_D[2],
	     DAUG_D[3]
	}),
	._OE(1'b0)
);

RAM_41464 U1J (
	._CAS(UxJ_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[7],
	     DAUG_D[6],
	     DAUG_D[4],
	     DAUG_D[5]
	}),
	._OE(1'b0)
);

RAM_41464 U1K (
	._CAS(UxK_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[7],
	     DAUG_D[6],
	     DAUG_D[4],
	     DAUG_D[5]
	}),
	._OE(1'b0)
);

RAM_41464 U2L (
	._CAS(UxL_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[11],
	     DAUG_D[10],
	     DAUG_D[8],
	     DAUG_D[9]
	}),
	._OE(1'b0)
);

RAM_41464 U2M (
	._CAS(UxM_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[11],
	     DAUG_D[10],
	     DAUG_D[8],
	     DAUG_D[9]
	}),
	._OE(1'b0)
);

RAM_41464 U1L (
	._CAS(UxL_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[15],
	     DAUG_D[14],
	     DAUG_D[12],
	     DAUG_D[13]
	}),
	._OE(1'b0)
);

RAM_41464 U1M (
	._CAS(UxM_CAS_d),
	.A({
	     DAUG_A[4],
	     DAUG_A[7],
	     DAUG_A[6],
	     DAUG_A[5],
	     DAUG_A[3],
	     DAUG_A[2],
	     DAUG_A[1],
	     DAUG_A[0]
	}),
	._WE(DAUG_RRW_d),
	._RAS(_RAS_d),
	.DQ({
	     DAUG_D[15],
	     DAUG_D[14],
	     DAUG_D[12],
	     DAUG_D[13]
	}),
	._OE(1'b0)
);

endmodule
