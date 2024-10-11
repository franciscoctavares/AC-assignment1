#this is the entry point of the program
.data
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"

PCB_BLOCKS: .space 1320 # 132 bytes x 10 Tasks
MAIN_TASK_PCB: .space 132 # for 32 register + epc

RUNNING_LIST: .word 0x00000000
READY_LIST: .word 0x00000000
LAST_READY: .word 0x00000000
AVAILABLE_LIST: .word 0x00000000

.eqv PCB_SIZE 136

.text
main:
# prepare the structures
	jal prep_multi
	la $a0, STRING_main
	loop:
		li $v0, 4
		syscall
		j loop
	li $v0, 10
	syscall
		
	
# newtask (t0)
	#la $a0, $t0
	li $a1, 1
	jal newtask
	li $v0, 10
	syscall
	
# newtask(t1)	
	#la $a0,t1
	li $a1,2
	jal newtask
# newtask(t2)
	#la $a0,t2
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
	sw $t0, AVAILABLE_LIST
	
	la $s0, RUNNING_LIST
	la $s1, READY_LIST
	la $s2, LAST_READY
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal int_enable
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
newtask:
	# write your code here
	jr $ra
    
start_multi:
	# write your code here
	jr $ra 

.include "interrupt.asm"
.include "t0.asm"
.include "t1.asm"
.include "t2.asm"

#END
