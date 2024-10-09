#this is the entry point of the program
	.data
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"
STACK_SIZE: .
ALL_PCBs: .space
AVAILABLE_PCB: .word ALL_PCBs
READY_PCBs: .word
RUNNING_PCB: .word 0x

	.text
main:
# prepare the structures	
	jal prep_multi
	
# newtask (t0)
	la $a0,t0
	li $a1, 1
	jal newtask
	
# newtask(t1)	
	la $a0,t1
	li $a1,2
	jal newtask
# newtask(t2)
	la $a0,t2
	l1 $a2, 3
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
	# write your code here 
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
