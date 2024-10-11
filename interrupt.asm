# you must put here the necessary code to deal with the interrupts
.data

PCB_BLOCKS: .space 1320 # 132 bytes x 10 Tasks

ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00010000

RCR: .word 0xffff0000

TEST_STRING: .asciiz "Writting stuff from the timer interrupt!\n"

.eqv PCB1 132
.eqv PCB3 396

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
	#la $a0, TEST_STRING
	move $a0, $s4
	jal save_registers
	
	beq $s4, 0, skip_loading
	
	li $a0, 0
	jal load_registers
	
	skip_loading:
	jal next_process # v0 = process id of next task
	
	li $a0, 0
	jal save_registers
	
	move $a0, $v0
	jal load_registers
	
	b int_end
	
	

# gravar registos do processo em execução
# carregar registos do processo principal
# atualizar registos e ponteiros para o próximo processo
# gravar registos do processo principal
# carregar registos do próximo processo
# sair da interrupção


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
	
# a0 = PCB offset
save_registers:
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)

	mulu $t0, $a0, PCB_SIZE
	
	la $t1, PCB_BLOCKS
	add $t1, $t1, $t0
	
	sw $at, 0($t1)
	sw $v0, 4($t1)
	sw $v1, 8($t1)
	sw $a0, 12($t1)
	sw $a1, 16($t1)
	sw $a2, 20($t1)
	sw $a3, 24($t1)
	#sw $t0,
	#sw $t1,
	sw $t2, 36($t1)
	sw $t3, 40($t1)
	sw $t4, 44($t1)
	sw $t5, 48($t1)
	sw $t6, 52($t1)
	sw $t7, 56($t1)
	sw $s0, 60($t1)
	sw $s1, 64($t1)
	sw $s2, 68($t1)
	sw $s3, 72($t1)
	sw $s4, 76($t1)
	sw $s5, 80($t1)
	sw $s6, 84($t1)
	sw $s7, 88($t1)
	sw $t8, 92($t1)
	sw $t9, 96($t1)
	sw $k0, 100($t1)
	sw $k1, 104($t1)
	sw $gp, 108($t1)
	sw $sp, 112($t1)
	sw $fp, 116($t1)
	sw $ra, 120($t1)
	
	mfc0 $t2, $14
	sw $t2, 124($t1)
	
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 8
	
	la $t2, PCB_BLOCKS
	
	sw $t0, 28($t2)
	sw $t1, 32($t2)
		
	jr $ra
	
# a0 = PCB offset
load_registers:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)

	mulu $t0, $a0, PCB_SIZE
	
	la $t1, PCB_BLOCKS
	add $t1, $t1, $t0
	
	lw $at, 0($t1)
	lw $v0, 4($t1)
	lw $v1, 8($t1)
	lw $a0, 12($t1)
	lw $a1, 16($t1)
	lw $a2, 20($t1)
	lw $a3, 24($t1)
	#sw $t0,
	#sw $t1,
	lw $t2, 36($t1)
	lw $t3, 40($t1)
	lw $t4, 44($t1)
	lw $t5, 48($t1)
	lw $t6, 52($t1)
	lw $t7, 56($t1)
	lw $s0, 60($t1)
	lw $s1, 64($t1)
	lw $s2, 68($t1)
	lw $s3, 72($t1)
	lw $s4, 76($t1)
	lw $s5, 80($t1)
	lw $s6, 84($t1)
	lw $s7, 88($t1)
	lw $t8, 92($t1)
	lw $t9, 96($t1)
	lw $k0, 100($t1)
	lw $k1, 104($t1)
	lw $gp, 108($t1)
	lw $sp, 112($t1)
	lw $fp, 116($t1)
	lw $ra, 120($t1)
	
	#mfc0 $t2, $14
	#sw $t2, 124($t1)
	
	lw $t2, 124($t1)
	mtc0 $t2, $14
	
	lw $ra, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 12
	
	la $t2, PCB_BLOCKS
	
	lw $t0, 28($t2)
	lw $t1, 32($t2)
		
	jr $ra
	
next_process:
	la $t0, PCB_BLOCKS
	addi $t0, $t0, PCB3
	
	beq $s0, $t0, last_task_running
	addi $s0, $s0, PCB1
	continue_ready:
	beq $s1, $t0, last_task_ready
	addi $s1, $s1, PCB1
	continue_lastready:
	beq $s2, $t0, last_task_lastready
	addi $s2, $s2, PCB1
	
	b done_switching
	
	last_task_running:
		addi $s0, $s0, -396 # -1 * PCB3
		b continue_ready
	last_task_ready:
		addi $s1, $s1, -396 # -1 * PCB3
		b continue_lastready
	last_task_lastready:
		addi $s2, $s2, -396 # -1 * PCB3
	done_switching:
		move $t0, $s0
		addi $t0, $t0, 76
		
		lw $v0, 0($t0) # next process id, to be returned from function
		
		jr $ra