#this is the entry point of the program

.data
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"

string_test_error: .asciiz "Pointers with wrong values!\n"
err1: .asciiz "ready pointer wrong!\n"
err2: .asciiz "last ready pointer wrong!\n"
err3: .asciiz "running pointer wrong!\n"
success_testing: .asciiz ""

test_string: .asciiz "Preparation done!\n"



RUNNING_LIST: .word 0x00000000
READY_LIST: .word 0x00000000
LAST_READY: .word 0x00000000
AVAILABLE_LIST: .word 0x00000000

.eqv PCB_SIZE 132
.eqv two_PCB_SIZE 264
.eqv three_PCB_SIZE 396
.eqv four_PCB_SIZE 528
.eqv MAX_PCB 1320

.text
main:
# prepare the structures
	jal prep_multi
	li $v0, 4
	la $a0, test_string
	syscall
		
	
# newtask (t0)
	la $a0, t0
	#li $a1, 1
	jal newtask
	
# newtask(t1)	
	la $a0, t1
	#li $a1,2
	jal newtask
	

# newtask(t2)
	la $a0, t2
	#li $a2, 3
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
	
	#sw $t0, MAIN_PCB # allocates the first PCB for the main task
	sw $t0, RUNNING_LIST # running process now points to the main task's PCB
	move $s0, $t0 # fix for new_task bug
	
	addi $t0, $t0, PCB_SIZE
	sw $t0, AVAILABLE_LIST
	
	li $s3, 1 # allocated PCB counter
	li $s4, 0 # process_id
	
	sw $s4, PCB_BLOCKS+76 # stores process id on the main task PCB
	
	jr $ra
	
newtask:
	bge $s3, 10, not_enough_space
	
	lw $t0, AVAILABLE_LIST
	bne $s3, 1, keep_going
	empty_list:
		move $s1, $t0 # ready = available
	keep_going:
		move $s2, $t0 # last ready = available
		addi $t0, $t0, PCB_SIZE
		sw $t0, AVAILABLE_LIST # available += PCB_SIZE
		li $v0, 0
		b done
	
	not_enough_space:
		li $v0, 1
	done:
		#li $t0
		addi $s3, $s3, 1 # increments the allocated PCB counter
		move $t0, $s3
		addi $t0, $t0, -1
		mulu $t1, $t0, PCB_SIZE
		addi $t1, $t1, 76
		la $t2, PCB_BLOCKS
		add $t2, $t2, $t1
		sw $t0, 0($t2) # stores the new process id on the correspondent PCB
		
		sub $t2, $t2, $t1
		addi $t2, $t2, 124
		sw $a0, 0($t2)
		
		
		la $a0, t0
		li $v0, 4
		syscall
		
		jr $ra
    
start_multi:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal int_enable
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra 

.include "interrupt.asm"
.include "t0.asm"
.include "t1.asm"
.include "t2.asm"

#END
