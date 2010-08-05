
void __start(void)
{
	volatile unsigned long * const wcs = (void *)0x00FC0000;
	volatile unsigned long * const rom = (void *)0x00F80000;
	unsigned long tmp;

	for (;;) {
		*wcs = 0xcafebeef;
		tmp = *wcs;
		tmp = *rom;
	}
}
