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

TEST_STRING: .asciiz "Writting stuff from the timer interrupt!\n"

.eqv PCB1 144
.eqv PCB3 432

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
	lw $a0, RUNNING
	print_int
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	la $a0, PCB_BLOCKS
	print_int
	new_line
	
	jal save_running_task_registers
	
	lw $a0, RUNNING
	print_int
	
	#la $t0, RUNNING
	lw $t0, RUNNING
	sw $t0, LAST_READY+140 # last_ready -> next = run
	
	#la $t0, RUNNING
	sw $t0, LAST_READY # last_ready = run

	lw $a0, RUNNING
	print_int

	#la $t0, READY
	lw $a0, READY
	print_int
	lw $t0, READY
	sw $t0, RUNNING # run = ready
	
	lw $a0, RUNNING
	print_int
	#new_line
	
	#la $t0, READY+140 # ready -> next
	lw $t0, READY+140
	sw $t0, READY # ready = ready -> next
	
	sw $zero, RUNNING+140 # run_next = null
	
	jal load_next_task_registers
	
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
	
save_running_task_registers:
	
	sw $at, RUNNING+0
	sw $v0, RUNNING+4
	sw $v1, RUNNING+8
	sw $a0, RUNNING+12
	sw $a1, RUNNING+16
	sw $a2, RUNNING+20
	sw $a3, RUNNING+24
	sw $t0, RUNNING+28
	sw $t1, RUNNING+32
	sw $t2, RUNNING+36
	sw $t3, RUNNING+40
	sw $t4, RUNNING+44
	sw $t5, RUNNING+48
	sw $t6, RUNNING+52
	sw $t7, RUNNING+56
	sw $s0, RUNNING+60
	sw $s1, RUNNING+64
	sw $s2, RUNNING+68
	sw $s3, RUNNING+72
	sw $s4, RUNNING+76
	sw $s5, RUNNING+80
	sw $s6, RUNNING+84
	sw $s7, RUNNING+88
	sw $t8, RUNNING+92
	sw $t9, RUNNING+96
	sw $k0, RUNNING+100
	sw $k1, RUNNING+104
	sw $gp, RUNNING+108
	sw $sp, RUNNING+112
	sw $fp, RUNNING+116
	sw $ra, RUNNING+120

	mfhi $t0
	sw $t0, RUNNING+124
	mflo $t0
	sw $t0, RUNNING+128
			
	mfc0 $t2, $14
	sw $t2, RUNNING+132 # epc
	
	# pid and next_pcb are not registers that need to be saved
	jr $ra
	
load_next_task_registers:
	lw $at, RUNNING+0
	lw $v0, RUNNING+4
	lw $v1, RUNNING+8
	lw $a0, RUNNING+12
	lw $a1, RUNNING+16
	lw $a2, RUNNING+20
	lw $a3, RUNNING+24
	
	lw $t0, RUNNING+132
	mtc0 $t0, $14 # load epc
	
	lw $t0, RUNNING+28
	lw $t1, RUNNING+32
	lw $t2, RUNNING+36
	lw $t3, RUNNING+40
	lw $t4, RUNNING+44
	lw $t5, RUNNING+48
	lw $t6, RUNNING+52
	lw $t7, RUNNING+56
	lw $s0, RUNNING+60
	lw $s1, RUNNING+64
	lw $s2, RUNNING+68
	lw $s3, RUNNING+72
	lw $s4, RUNNING+76
	lw $s5, RUNNING+80
	lw $s6, RUNNING+84
	lw $s7, RUNNING+88
	lw $t8, RUNNING+92
	lw $t9, RUNNING+96
	lw $k0, RUNNING+100
	lw $k1, RUNNING+104
	lw $gp, RUNNING+108
	lw $sp, RUNNING+112
	lw $fp, RUNNING+116
	#lw $ra, RUNNING+120
	
	jr $ra
