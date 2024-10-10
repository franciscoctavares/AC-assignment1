# you must put here the necessary code to deal with the interrupts
.data

ALL_INT_MASK: .word 0x0000ff00
TIMER_INT_MASK: .word 0x00008000

.text
int_enable:
	mfc0 $t0, $12
	
	lw $t1, ALL_INT_MASK
	not $t1,$t1
	and $t0,$t0,$t1 # disable all interrupts
	
	lw $t1, TIMER_INT_MASK
	or $t0,$t0,$t1 # activate timer interrupt
	
	mtc0 $t0, $12
	
	jr $ra
