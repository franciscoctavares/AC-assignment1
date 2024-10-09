#this is the entry point of the program
	.data
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"
PCB_BLOCKS: .space 1360 # 136 bytes x 10 Tasks
MAIN_TASK_PCB: .space 136 # for 32 register + epc
RUNNING_LIST: .word 0
READY_LIST: .word 0
NEXT_PCB: .word 136
NEXT_POINTER: .word 132

#.eqv NEXT_PCB 136
.eqv PCB_NEXT_POINTER 132 # pointer to next pcb block
	.text
main:
# prepare the structures
	li $v0, 1
	li $a0, 10
	syscall
	jal prep_multi
	
# newtask (t0)
	la $a0,t0
	li $a1, 1
	jal newtask
	li $v0, 10
	syscall
	
# newtask(t1)	
	la $a0,t1
	li $a1,2
	jal newtask
# newtask(t2)
	la $a0,t2
	li $a2, 3
	jal newtask

# startmulti() and continue to 
# the infinit loop of the main function
	jal start_multi
	
	la $a0, STRING_done
	li $v0, 4
	syscall
	
infinit: 
	# Reapeatedly print a string
	la $a0, STRING_main
	li $v0, 4
	syscall
	b infinit

# the support functions	
prep_multi:
	la $t0, PCB_BLOCKS
	li $t1, 0
	
	loop:
		li $v0, 1
		li $a0, 10
		syscall
		
		la $t2, NEXT_PCB($t0)
		sw $t2, 10($t0)
		addi $t0, $t0, 136
		addi $t1, $t1, 1
		ble $t1, 2, loop
		
		la $s0, RUNNING_LIST
		la $s1, READY_LIST
	
		jr $ra
	
newtask:
	# write your code here
	jr $ra
    
start_multi:
	# write your code here
	jr $ra 

	.include "t0.asm"
	.include "t1.asm"
	.include "t2.asm"
	.include "interrupt.asm"
#END
