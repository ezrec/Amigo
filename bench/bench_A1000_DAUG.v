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
`timescale 1us/1ps
`default_nettype none

module bench_A1000_DAUG (
);

reg J1, J2;
reg [23:0] A;
wire [15:0] D;
reg _LDS;
reg _UDS;
reg _PRW;
wire _DTACK;
reg _AS;
reg _DBR;
reg OVL;
reg _OVR;
reg XRDY;
wire _ROME;
wire _ROM01;
reg _RST;

wire VCC;
wire GND;

assign VCC = 1'b1;
assign GND = 1'b0;

pullup (weak1) (_DTACK);

// 28.63636 Mhz clock
wire CLK_NTSC;

Clock #(.clock_rate(28636360)) OSC1 (
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

reg [15:0] D_in;

genvar i;
generate
	for (i = 0; i < 8; i = i + 1) begin :Dbuf
		bufif1(D[i + 0], D_in[i + 0], ~_PRW && ~_LDS);
		bufif1(D[i + 8], D_in[i + 8], ~_PRW && ~_UDS);
	end
endgenerate

Amiga_A1000_DAUG A1000_DAUG (
	.J1_ENABLE(J1),
	.J2_ENABLE(J2),
	.A(A[23:1]),
	.D(D),
	._LDS(_LDS),
	._UDS(_UDS),
	._PRW(_PRW),
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

	.VCC(VCC),
	.GND(GND)
);

initial begin
	J1 <= 1'b1;
	J2 <= 1'b1;
	A <= 24'b0;
	_LDS <= 1'b1;
	_UDS <= 1'b1;
	_PRW <= 1'b1;
	_AS <= 1'b1;
	_DBR <= 1'b1;
	OVL <= 1'b1;
	_OVR <= 1'b1;
	XRDY <= 1'b1;
	_RST <= 1'b0;
end

task addr_strobe;
	input [23:0] addr;
	input r_w;

begin
	_PRW <= r_w;
	_AS <= 1'b0;
	_UDS <= 1'b0;
	_LDS <= 1'b0;
	A <= addr;
	#100;
	_AS <= 1'b1;
	_UDS <= 1'b1;
	_LDS <= 1'b1;
	A <= 24'hzzzzzz;
	_PRW <= 1'b1;
	#10;
end
endtask

initial begin
	$dumpfile("bench_A1000_DAUG.vcd");
	$dumpvars(100, bench_A1000_DAUG);
	J2 <= 1'b0;
	OVL <= 1'b1;
	D_in <= 16'h1234;
//	_OVR <= 1'b0;

	_RST <= 1'b1;
	#100;
	addr_strobe(24'h000000, 1);

	OVL <= 1'b0;
	addr_strobe(24'hf80000, 1);

	_OVR <= 1'b1;
	addr_strobe(24'he00000, 0);
	addr_strobe(24'he00000, 1);
	addr_strobe(24'he40000, 0);
	addr_strobe(24'he40000, 1);

	addr_strobe(24'he80000, 0);
	addr_strobe(24'he80000, 1);
	addr_strobe(24'hec0000, 0);
	addr_strobe(24'hec0000, 1);

	addr_strobe(24'hf00000, 0);
	addr_strobe(24'hf00000, 1);

	addr_strobe(24'hf40000, 0);
	addr_strobe(24'hf40000, 1);

	addr_strobe(24'hfc0000, 0);
	addr_strobe(24'hfc0000, 1);

	addr_strobe(24'hf80000, 0);
	addr_strobe(24'hf80000, 1);

	addr_strobe(24'hfc0000, 0);
	addr_strobe(24'hfc0000, 1);


	$finish;
end

endmodule
