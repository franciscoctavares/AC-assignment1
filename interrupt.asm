# you must put here the necessary code to deal with the interrupts

.data
	TIMER_INT_MASK: .word 0x
enable_interrupts:
	mfc0 $t0, $12
	jr $ra