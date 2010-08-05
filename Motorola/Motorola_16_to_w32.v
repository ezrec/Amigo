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

module Motorola_16_to_w32 (
	/* Motorola Signals */
	inout	_RST,
	inout	_HLT,
	input 	CLK,
	output	_AS,
	output	[23:1] A,
	inout	[15:0] D,
	output	E,
	input	_VPA,
	output	_VMA,
	output	R_W,
	output	_LDS,
	output	_UDS,
	input	_DTACK,
	input	[2:0] _IPL,
	output	[2:0] _FC,
	input	VCC,
	input	GND,

	/* Wishbone Signals */
	output	RST_O,
	input	reset_i,
	input	blocked_i,
	output	CLK_O,

	input	WE_I,
	input	CYC_I,
	input	[31:2] ADR_I,
	input	[31:0] DAT_I,
	output	[31:0] DAT_O,
	input	STB_I,
	input	[3:0] SEL_I,
	output	ACK_O,

	output	[2:0] ipl_o,
	input	[2:0] fc_i
);

/* Motorola bus reset is driven by Wishbone reset request
 */
bufif1(_RST, 1'b0, reset_i);

/*
 * We're out of reset if we have GND, VCC, and _RST is high
 */
assign RST_O = !((_RST == 1) && (VCC == 1) && (GND == 0));

/* VMA/VPA/E simulation
 * E is a divide by 10 of CLK, with 6 cycles off, and 4 cycles on.
 */
reg [9:0] E_ring;
assign E = E_ring[0] && (!RST_O);
reg VMA;
wire VPA;

assign VPA = !_VPA;
assign _VMA = !VMA;

always @(posedge RST_O or posedge CLK)
	if (!RST_O) begin
		E_ring = 10'hf;
	end else begin
		E_ring <= {E_ring[0],E_ring[9:1]};
	end

always @(posedge RST_O or posedge CLK)
	if (RST_O) begin
		VMA <= 1'b0;
	end else begin
		if (!E) begin
			if (VPA) begin
				VMA <= 1'b1;
			end else begin
				VMA <= 1'b0;
			end
		end
	end

/* DTACK and VPA can't be asserted at the same time
 * Motoroal M68K manual, page B-4, paragraph 4
 */
always @(negedge _DTACK or negedge _VPA)
	if (!_DTACK && !_VPA) begin
		$display("M68000 Fatal bus error: _DTACK and _VPA both asserted (to 0)");
		$finish();
	end

/* D_stage = 0 - noop
 * D_stage = 1 - Send/Recv ADDR + 2
 * D_stage = 2 - Send/Recv ADDR + 0
 * D_stage = 3 - Finish
 */
reg [1:0]  D_stage;
reg [31:0] Di_hold;
reg [31:0] Do_hold;
reg [15:0] Do;
reg [15:0] Di;

reg lds;
reg uds;
reg as;
reg ack;

assign A[23:1] = {ADR_I[23:2],D_stage[0]};
assign R_W = !WE_I;
assign _AS = !as;
assign _FC = !fc_i;
assign ipl_o = !_IPL;
assign _LDS = !lds;
assign _UDS = !uds;
assign DAT_O = Di_hold;
assign ACK_O = ack;

genvar i;
generate
	for (i = 0; i < 16; i = i + 1) begin : DATA
		bufif0(D[i], Do[i], R_W);
	end
endgenerate

/* Split up data accesses.
 * A little tricky, because some strobes turn into two reads
 * or two writes.
 */
always @(posedge RST_O or posedge CLK_O)
	if (RST_O == 1) begin
		D_stage <= 0;
		lds <= 0;
		uds <= 0;
		as <= 0;
		ack <= 0;
		Do[15:0] <= 16'hzzzz;
	end else if (STB_I == 0) begin
		D_stage <= 1;
		ack <= 0;
		as <= 0;
	end else if (STB_I == 1) begin
		case (D_stage)
		0: begin	/* No-op */
		   	ack <= 0;
		   	Di_hold <= 32'hzzzzzzzz;
		   end
		1: begin	/* R/W lower two bytes */
			Do[15:0] <= DAT_I[15:0];
			lds <= SEL_I[0];
			uds <= SEL_I[1];
			as <= 1;
			if (_DTACK == 0) begin
				Di_hold[15:0] <= D[15:0];
				D_stage <= 2;
				as <= 0;
			end
		   end
		2: begin	/* R/W upper two bytes */
			Do[15:0] <= DAT_I[31:16];
			lds <= SEL_I[2];
			uds <= SEL_I[3];
			as <= 1;
			if (_DTACK == 0) begin
				Di_hold[31:16] <= D[15:0];
				D_stage <= 3;
				as <= 0;
			end
		   end
		3: begin	/* Finish transaction */
			ack <= 1;
			D_stage <= 0;
		   end
		endcase
	end

assign CLK_O = CLK && _HLT;

endmodule
