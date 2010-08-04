/*
 * Copyright (C) 2010, Jason S. McMullan
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

/* NOTE: This matches the M68000 pinout,
 *       and uses the Amiga 500 signal names - mostly
 */
module Motorola_68000 (
	inout	[15:0] D,
	output	_AS,
	output	_UDS,
	output	_LDS,
	output	R_W,
	input	_DTACK,
	output  _BG,
	input	_BGACK,
	input	_BR,
	input	CLK,	// NOTE: Called '7M' in AMIGA docs
	inout	_HLT,
	inout	_RST,
	output	_VMA,
	output	E,
	input	_VPA,
	input	_BERR,
	input	[2:0] _IPL,
	output	[2:0] _FC,
	output	[23:1] A,
	input	VCC,	// VCC placeholder
	input	GND	// GND placeholder
);

wire wRST, wreset, wblocked, wCLK, wWE, wCYC;
wire [31:2] wADR;
wire [31:0] wDATi;
wire [31:0] wDATo;
wire wSTB, wACK;
wire [3:0] wSEL;
wire [2:0] wipl;
wire [2:0] wfc;

/* Adapter between Motorola 16bit and Wishbone 32bit
 */
Motorola_16_to_w32 m16_to_w32 (
	/* Motorola */
	._RST(_RST),
	._HLT(_HLT),
	.CLK(CLK),
	._AS(_AS),
	.A(A),
	.D(D),
	.E(E),
	._VPA(_VPA),
	._VMA(_VMA),
	.R_W(R_W),
	._LDS(_LDS),
	._UDS(_UDS),
	._DTACK(_DTACK),
	._IPL(_IPL),
	._FC(_FC),
	.VCC(VCC),
	.GND(GND),

	/* Wishbone */
	.RST_O(wRST),
	.reset_i(wreset),
	.blocked_i(wblocked),
	.ipl_o(wipl),
	.fc_i(wfc),
	.CLK_O(wCLK),
	.WE_I(wWE),
	.CYC_I(wCYC),
	.ADR_I(wADR),
	.DAT_I(wDATo),
	.DAT_O(wDATi),
	.STB_I(wSTB),
	.SEL_I(wSEL),
	.ACK_O(wACK)
);

`ifdef M68K_IS_AO68000
ao68000 cpu (
	.RST_I(wRST),
	.CLK_I(wCLK),

	.CYC_O(wCYC),
	.ADR_O(wADR),
	.DAT_I(wDATi),
	.DAT_O(wDATo),
	.WE_O(wWE),
	.SEL_O(wSEL),
	.STB_O(wSTB),
	.ACK_I(wACK),

	.RTY_I(1'b0),
	.ERR_I(1'b0),

	.ipl_i(wipl),
	.fc_o(wfc),
	.reset_o(wreset),
	.blocked_o(wblocked)
);
`endif

`ifdef M68K_IS_UCORE

// M68K emulation is in an embedded ROM
reg [31:0] ucore_rom[0:4095];
wire ucr_CYC;
wire ucr_STB;
wire [31:0] ucr_ADR;
reg [31:0] ucr_DATi;
reg ucr_ACK;

assign wreset = 1'b0;
assign wblocked = 1'b0;
assign wfc = 3'b000;

integer fd, err;
initial begin
	fd = $fopenr("ucore.bin");
	err = $fread(ucore_rom, fd);
	$fclose(fd);
end

always @(posedge wRST or posedge wCLK)
	if (wRST == 1) begin
		ucr_DATi <= 32'bzzzzzzzz;
		ucr_ACK <= 1'bz;
	end else if (ucr_CYC == 1) begin
		if (ucr_ACK == 0 && ucr_STB == 1) begin
			ucr_DATi <= ucore_rom[ucr_ADR[31:2]];
			ucr_ACK <= 1;
		end else begin
			ucr_ACK <= 0;
		end
	end

wire [31:0] wADRr;
wire [31:0] wADRw;

genvar i;
generate 
	for (i = 2; i < 32; i = i + 1) begin : ADR
		bufif1(wADR[i], wADRw[i], wWE);
		bufif0(wADR[i], wADRr[i], wWE);
	end
endgenerate

ucore cpu (
	.rst_i(wRST),
	.clk_i(wCLK),

	.imem_cyc_o(ucr_CYC),
	.imem_stb_o(ucr_STB),
	.imem_addr_o(ucr_ADR),
	.imem_ack_i(ucr_ACK),
	.imem_inst_i(ucr_DATi),

	.dmem_cyc_o(wCYC),
	.dmem_stb_o(wSTB),
	.dmem_we_o(wWE),
	.dmem_bwsel_o(wSEL),
	.dmem_raddr_o(wADRr),
	.dmem_waddr_o(wADRw),
	.dmem_data_o(wDATo),
	.dmem_data_i(wDATi),
	.dmem_ack_i(wACK),

	.it_hw_i({1'b0,wipl}),
	.nmi_i(1'b0)
);


`endif // M68K_IS_UCORE

endmodule
