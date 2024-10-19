# you must put here the necessary code to deal with the interrupts

.include "macros.asm"

.data

PCB_BLOCKS: .space 1440 # 132 bytes x 10 Tasks
RUNNING: .word 0x00000000
READY: .word 0x00000000
LAST_READY: .word 0x00000000

RUNNING_str: .asciiz "RUNNING: "

ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00010000

RCR: .word 0xffff0000

next_str: .asciiz " -> "

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
	jal print_PCB_sequence
	jal print_pointers
	
	jal save_running_task_registers
	
	lw $t0, RUNNING
	lw $t0, 0($t0) # bug fix
	lw $t1, LAST_READY
	sw $t0, 140($t1) # last_ready -> next = run
	
	lw $t0, RUNNING
	lw $t1, LAST_READY
	sw $t0, 0($t1) # last_ready = run

	#####
	lw $t0, READY
	#lw $t0, 0($t0)
	sw $t0, RUNNING # run = ready
	#####
	
	lw $t0, READY
	lw $t0, 140($t0) # t0 = ready -> next
	lw $t1, READY
	sw $t0, 0($t1) # ready = ready -> next	
	
	lw $t0, RUNNING
	sw $zero, 140($t0) # run -> next = null
	
	jal load_next_task_registers
	
	jal print_pointers
	
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
	
save_running_task_registers:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	lw $t0, RUNNING
	
	sw $at, 0($t0)
	sw $v0, 4($t0)
	sw $v1, 8($t0)
	sw $a0, 12($t0)
	sw $a1, 16($t0)
	sw $a2, 20($t0)
	sw $a3, 24($t0)
	#sw $t0, 28($t0)
	sw $t1, 32($t0)
	sw $t2, 36($t0)
	sw $t3, 40($t0)
	sw $t4, 44($t0)
	sw $t5, 48($t0)
	sw $t6, 52($t0)
	sw $t7, 56($t0)
	sw $s0, 60($t0)
	sw $s1, 64($t0)
	sw $s2, 68($t0)
	sw $s3, 72($t0)
	sw $s4, 76($t0)
	sw $s5, 80($t0)
	sw $s6, 84($t0)
	sw $s7, 88($t0)
	sw $t8, 92($t0)
	sw $t9, 96($t0)
	sw $k0, 100($t0)
	sw $k1, 104($t0)
	sw $gp, 108($t0)
	sw $sp, 112($t0)
	sw $fp, 116($t0)
	sw $ra, 120($t0)

	lw $t1, RUNNING

	mfhi $t0
	sw $t0, 124($t1) # hi
	
	mflo $t0
	sw $t0, 128($t1) # lo
			
	mfc0 $t0, $14
	sw $t0, 132($t1) # epc
	
	lw $t0, 0($sp)
	lw $t1, RUNNING
	sw $t0, 28($t1)
	
	addi $sp, $sp, 4
	
	jr $ra
	
load_next_task_registers:
	lw $t0, RUNNING

	lw $at, 0($t0)
	lw $v0, 4($t0)
	lw $v1, 8($t0)
	lw $a0, 12($t0)
	lw $a1, 16($t0)
	lw $a2, 20($t0)
	lw $a3, 24($t0)
	
	lw $t1, 132($t0)
	mtc0 $t1, $14 # load next task's epc
	
	lw $t1, 32($t0)
	lw $t2, 36($t0)
	lw $t3, 40($t0)
	lw $t4, 44($t0)
	lw $t5, 48($t0)
	lw $t6, 52($t0)
	lw $t7, 56($t0)
	lw $s0, 60($t0)
	lw $s1, 64($t0)
	lw $s2, 68($t0)
	lw $s3, 72($t0)
	lw $s4, 76($t0)
	lw $s5, 80($t0)
	lw $s6, 84($t0)
	lw $s7, 88($t0)
	lw $t8, 92($t0)
	lw $t9, 96($t0)
	lw $k0, 100($t0)
	lw $k1, 104($t0)
	lw $gp, 108($t0)
	lw $sp, 112($t0)
	lw $fp, 116($t0)
	
	lw $t0, 28($t0) # finally load t0
	
	jr $ra
	
print_pointers:
	la $a0, BASE_ADDR
	print_string
	la $a0, PCB_BLOCKS
	print_pointer
	
	new_line
	
	la $a0, AVAILABLE_str
	print_string
	lw $a0, AVAILABLE
	print_pointer
	
	new_line
	
	la $a0, READY_str
	print_string
	lw $a0, READY
	print_pointer
	
	new_line
	
	la $a0, LAST_READY_str
	print_string
	lw $a0, LAST_READY
	print_pointer
	
	new_line
	
	la $a0, RUNNING_str
	print_string
	lw $a0, RUNNING
	print_pointer
	
	new_line
	new_line
	
	jr $ra
	
print_PCB_sequence:
	la $a0, PCB_BLOCKS
	
	
	
	
	
	jr $ra
