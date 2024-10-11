# you must put here the necessary code to deal with the interrupts
.data

ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00010000

RCR: .word 0xffff0000

TEST_STRING: .asciiz "Writting stuff from the timer interrupt!"

.text
int_enable:
	mfc0 $t0 , $12
	lw $t1 , ALL_INT_MASK
	not $t1 , $t1
	and $t0 , $t0 , $t1 # disable all int
	lw $t1, KBD_INT_MASK
	or $t0, $t0, $t1
	mtc0 $t0 , $12
	
	# now enable keyboard interrupts
	lw $t0, RCR
	li $t1 , 0x00000002
	sw $t1 0($t0)
	
	jr $ra

.kdata

save_v0 : .word
save_at: .word

.ktext 0x80000180

move $k0 , $at
sw $k0 , save_at
sw $v0 , save_v0

mfc0 $k0 , $13 # get cause register
srl $t1 , $k0 ,2
andi $t1 , $t1 ,0x1f # extract bits 2?6
bnez $t1 , non_int #
andi $t2 , $k0 ,0x00000100 # is bit 8 set?
bnez $t2 , timer_int
b int_end

non_int:
	mfc0 $k0 , $14
	addiu $k0 , $k0 ,4
	mtc0 $k0 , $14
	b int_end

timer_int:
	la $a0, TEST_STRING

int_end:
	lw $v0 , save_v0
	lw $k0 , save_at
	move $at , $k0
	mtc0 $zero , $13
	mfc0 $k0 , $12
	andi $k0 , 0xfffd
	ori $k0 , 0x0001
	mtc0 $k0 , $12
	eret
