# you must put here the necessary code to deal with the interrupts

.data
enable_interrupts:
	mfc0 $t0, $12
	jr $ra
	li $v0, 5
