#this is the entry point of the program

.macro print_string
	li $v0, 4
	syscall
.end_macro

.data
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"

string_test_error: .asciiz "Pointers with wrong values!\n"
err1: .asciiz "ready pointer wrong!\n"
err2: .asciiz "last ready pointer wrong!\n"
err3: .asciiz "running pointer wrong!\n"
success_testing: .asciiz ""

test_string: .asciiz "Preparation done!\n"

available_str: .asciiz "AVAILABLE: "
READY_str: .asciiz "READY: "
READY_LAST_str: .asciiz "READY_LAST: "
BASE_ADDR: .asciiz "PCB_BLOCKS: "
NEXT_PCB_str: .asciiz "NEXT PCB: "


#RUNNING_LIST: .word 0x00000000
#READY_LIST: .word 0x00000000
#LAST_READY: .word 0x00000000
CREATED_TASK_COUNTER: .word 0x00000000
AVAILABLE: .word 0x00000000

.eqv PCB_SIZE 144
.eqv two_PCB_SIZE 288
.eqv three_PCB_SIZE 432
.eqv four_PCB_SIZE 528
.eqv MAX_PCB 1440

.eqv 

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
	
	#jal test_PCB
	
# newtask(t1)	
	la $a0, t1
	#li $a1,2
	jal newtask
	
	#jal test_PCB

# newtask(t2)
	la $a0, t2
	#li $a2, 3
	jal newtask
	
	#jal test_PCB

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
	
	la $a0, BASE_ADDR
	print_string
	la $a0, PCB_BLOCKS
	li $v0, 1
	syscall
	
	b infinit

# the support functions	
prep_multi:
	la $t0, PCB_BLOCKS
	
	sw $t0, RUNNING # running process now points to the main task's PCB
	
	la $a0, PCB_BLOCKS
	li $v0, 1
	syscall
	
	li $v0, 11
	li $a0, ' '
	syscall
	
	lw $a0, RUNNING
	li $v0, 1
	syscall
	
	la $t0, PCB_BLOCKS
	addi $t0, $t0, PCB_SIZE
	sw $t0, AVAILABLE # available = available -> next
		lw $a0, AVAILABLE
		li $v0, 1
		syscall
	
	li $t1, 1
	sw $t1, CREATED_TASK_COUNTER # created tasks = 1
	
	li $t1, 0
	sw $t1, RUNNING+136 # stores main task's process id in the PCB
	
	jr $ra
	
newtask:
	lb $t0, CREATED_TASK_COUNTER
	bge $t0, 10, done
	
	#bne $t0, 1, keep_going
	bnez $t0, non_empty_list
	empty_list:
		lw $t0, AVAILABLE
		sw $t0, READY # ready = available
		#move $a0, $t0
		lw $a0, AVAILABLE
		li $v0, 1
		syscall
	non_empty_list:
		lw $t0, AVAILABLE
		sw $t0, LAST_READY # last ready = available
		
		addi $t0, $t0, PCB_SIZE
		sw $t0, AVAILABLE # available += PCB_SIZE

		lb $t0, CREATED_TASK_COUNTER
		addi $t0, $t0, 1
		sb $t0, CREATED_TASK_COUNTER # task counter += 1
		
		
		#move $t0, $s3
		lb $t0, CREATED_TASK_COUNTER
		#move $a0, $t0
		#li $v0, 1
		#syscall
		addi $t0, $t0, -1
		
		mulu $t1, $t0, PCB_SIZE # $t1 = (task counter - 1) * 144(PCB_SIZE)
		addi $t1, $t1, 136
		la $t2, PCB_BLOCKS
		add $t2, $t2, $t1
		sw $t0, 0($t2) # stores the new process id on the correspondent PCB
		
		sub $t2, $t2, $t1
		addi $t2, $t2, 132
		sw $a0, 0($t2) # stores the new task's starting adress in the PCB's slot for the epc register	
	done:
		jr $ra
    
start_multi:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal int_enable
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra 

test_PCB:
	la $t0, PCB_BLOCKS
	
	move $a0, $t0
	li $v0, 4
	syscall
	
	# print space
	li $v0, 11
	li $a0, 32
	syscall
	
	lw $a0, 136($t0)
	li $v0, 1
	syscall
	
	lw $a0, 140($t0)
	li $v0, 1
	syscall
	
	li $v0, 11
	li $a0, 10
	addi $t0, $t0, PCB_SIZE

	move $a0, $t0
	li $v0, 4
	syscall
	
	# print space
	li $v0, 11
	li $a0, 32
	syscall
	
	lw $a0, 136($t0)
	li $v0, 1
	syscall
	
	lw $a0, 140($t0)
	li $v0, 1
	syscall

	li $v0, 11
	li $a0, 10
	addi $t0, $t0, PCB_SIZE
	
	move $a0, $t0
	li $v0, 4
	syscall
	
	# print space
	li $v0, 11
	li $a0, 32
	syscall
	
	lw $a0, 136($t0)
	li $v0, 1
	syscall
	
	lw $a0, 140($t0)
	li $v0, 1
	syscall
	
	jr $ra

.include "interrupt.asm"
.include "t0.asm"
.include "t1.asm"
.include "t2.asm"

#END
