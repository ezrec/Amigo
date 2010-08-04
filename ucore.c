
void __start(void)
{
	volatile unsigned long * const stuff = (void *)0x00FC0000;

	for (;;)
		*stuff = 0xdeadcafe;
}
