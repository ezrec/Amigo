PATH := $(PATH):/opt/mips-4.4/bin

all: ucore.bin testbench.ucore.sim

.PRECIOUS: %.elf

testbench.ao68000.sim: testbench.v A1000.v
	iverilog -o $@ \
		-y TTL -y IO -y Amiga -y MOS -y Motorola \
		-y ao68000/rtl/verilog/ao68000 \
		-y ao68000/rtl/verilog/ao68000/generic -I ao68000/rtl/verilog/ao68000 \
		-DM68K_IS_AO68000 \
		-y RAM $^

testbench.ucore.sim: testbench.v A1000.v
	iverilog -o $@ \
		-y TTL -y IO -y Amiga -y MOS -y Motorola \
		-y ucore -I ucore \
		-DM68K_IS_UCORE \
		-y RAM $^

%.bin: %.elf
	mips-sde-elf-objcopy $*.elf -Obinary $*.bin

%.elf: %.c
	mips-sde-elf-gcc -Wl,--section,.text=0 -O3 -o $*.elf $*.c -nostdlib


clean:
	$(RM) testbench.*.sim
