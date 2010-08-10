`timescale 1ns/1ps
`default_nettype none

module bench_A1000(
);

wire _RST;
reg reset;

bufif1(_RST, 1'b0, reset);

wire _C1;
wire _OVR;
reg override;

bufif1(_OVR, 1'b0, override);

Amiga_A1000 A1000 (
	.VCC_5V(1'b1),
	.GND(1'b0),

	._C1(_C1),
	._OVR(_OVR),
	._RST(_RST)
);

integer ticks;

initial begin
	$dumpfile("bench_A1000.vcd");
	$dumpvars(100, bench_A1000);
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
