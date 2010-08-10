PATH := $(PATH):/opt/mips-4.4/bin

all: ucore.bin A1000.ucore.sim

VERILOG_LIBS=TTL IO Amiga MOS Motorola Resistor LED Jumper Clock

.PRECIOUS: %.elf

%.ao68000.sim: bench/bench_%.v
	iverilog -o $@ \
		$(VERILOG_LIBS:%=-y %) \
		-y ao68000/rtl/verilog/ao68000 \
		-y ao68000/rtl/verilog/ao68000/generic -I ao68000/rtl/verilog/ao68000 \
		-DM68K_IS_AO68000 \
		-y RAM $^

%.ucore.sim: bench/bench_%.v
	iverilog -o $@ \
		$(VERILOG_LIBS:%=-y %) \
		-y ucore -I ucore \
		-DM68K_IS_UCORE \
		-y RAM $^

%.bin: %.elf
	mips-sde-elf-objcopy $*.elf -Obinary $*.bin

%.elf: %.c
	mips-sde-elf-gcc -Wl,--section,.text=0 -O3 -o $*.elf $*.c -nostdlib


clean:
	$(RM) *.sim *.vcd
