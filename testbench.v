`timescale 1ns/1ps
`default_nettype none

module testbench;

wire _RST;
reg reset;

bufif1(_RST, 1'b0, reset);

wire _C1;
wire _OVR;
reg override;

bufif1(_OVR, 1'b0, override);

A1000 A1000 (
	.VCC_5V(1'b1),
	.GND(1'b0),

	._C1(_C1),
	._OVR(_OVR),
	._RST(_RST)
);

integer ticks;

initial begin
	$dumpfile("testbench.vcd");
	$dumpvars(100, testbench);
	ticks = 0;
	reset = 1'b1;
	override = 1'b0;
	#100 reset = 1'b0;
end

always @(posedge _C1)
	begin
		ticks = ticks + 1;
		if (ticks >= 1000)
			$finish();
	end

endmodule
