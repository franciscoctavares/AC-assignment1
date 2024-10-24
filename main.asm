#this is the entry point of the program

.macro print_string
	li $v0, 4
	syscall
.end_macro

.macro print_pointer
	li $v0, 1
	syscall
.end_macro

.macro new_line
	li $v0, 11
	li $a0, 10
	syscall
.end_macro

.macro print_space
	li $v0, 11
	li $a0, 32
	syscall
.end_macro

.data
STRING_done: .asciiz "Multitask started\n"
STRING_main0: .asciiz "Starting main task...\n"
STRING_main1: .asciiz "Main Task - "
string_test_error: .asciiz "Pointers with wrong values!\n"
err1: .asciiz "ready pointer wrong!\n"
err2: .asciiz "last ready pointer wrong!\n"
err3: .asciiz "running pointer wrong!\n"
success_testing: .asciiz ""

test_string: .asciiz "Preparation done!\n"

empty_list_str: .asciiz "empty list!"
AVAILABLE_str: .asciiz "AVAILABLE: "
#READY_str: .asciiz "READY: "
LAST_READY_str: .asciiz "LAST_READY: "
#BASE_ADDR: .asciiz "PCB_BLOCKS: "

CREATED_TASK_COUNTER: .word 0x00000000
AVAILABLE: .word 0x00000000

.eqv PCB_SIZE 144

.text

main:
# prepare the structures	
	jal prep_multi
	li $v0, 4
	la $a0, test_string
	syscall
		
	
# newtask (t0)
	la $a0, t0
	jal newtask
	#jal print_all_pointers
	
# newtask(t1)	
	la $a0, t1
	jal newtask
	#jal print_all_pointers

# newtask(t2)
	la $a0, t2
	jal newtask
	#jal print_all_pointers

# startmulti() and continue to 
# the infinit loop of the main function
	jal fix_linked_list
	jal start_multi
	
	la $a0, STRING_done
	li $v0, 4
	syscall
	
infinit: 
	# Reapeatedly print a string
	li $t0, 0
	la $a0, STRING_main0
	li $v0, 4
	syscall
	loop:
		la $a0, STRING_main1
		li $v0, 4
		syscall
		move $a0, $t0
		li $v0, 1
		syscall
		new_line
		addi $t0, $t0, 1
		b loop

# the support functions	
prep_multi:
	la $t0, PCB_BLOCKS
	
	sw $t0, RUNNING # running process now points to the main task's PCB
	
	la $t0, PCB_BLOCKS
	addi $t0, $t0, PCB_SIZE
	sw $t0, AVAILABLE # available = available -> next
	
	li $t1, 1
	sw $t1, CREATED_TASK_COUNTER # created tasks = 1
	
	li $t0, 0
	lw $t1, RUNNING
	sw $t0, 136($t0) # stores main task's process id in the PCB
	
	jr $ra
	
newtask:
	move $s0, $a0 # save the starting adress of the new task in s0
	
	lb $t0, CREATED_TASK_COUNTER
	bge $t0, 10, done
	bne $t0, 1, non_empty_list
	empty_list:
		lw $t0, AVAILABLE
		sw $t0, READY # ready = available
	non_empty_list:
		lw $t0, AVAILABLE
		sw $t0, LAST_READY # LAST_READY = AVAILABLE
		
		addi $t0, $t0, PCB_SIZE
		sw $t0, AVAILABLE # AVAILABLE += PCB_SIZE

		lb $t0, CREATED_TASK_COUNTER
		addi $t0, $t0, 1
		sb $t0, CREATED_TASK_COUNTER # CREATED_TASK_COUNTER += 1
		
		lb $t0, CREATED_TASK_COUNTER
		addi $t0, $t0, -1
		
		mulu $t1, $t0, PCB_SIZE # t1 = (CREATED_TASK_COUNTER - 1) * PCB_SIZE
		addi $t1, $t1, 136
		la $t2, PCB_BLOCKS
		add $t2, $t2, $t1
		sw $t0, 0($t2) # stores the new process id on the correspondent PCB
		
		sw $s0, -4($t2) # new task's starting address(epc)
		
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
	
fix_linked_list:
	lw $s0, READY # s0 = task0
	
	addi $t0, $s0, PCB_SIZE # t0 = task0 -> next
	sw $t0, 140($s0) # task0 -> task1
	
	addi $s0, $s0, PCB_SIZE # s0 = task1
	addi $t0, $s0, PCB_SIZE # t0 = task1 -> next
	sw $t0, 140($s0) # task1 -> task2
	
	addi $s0, $s0, PCB_SIZE
	sw $zero, 140($s0) # task2 -> null
	
	jr $ra

.include "interrupt.asm"
.include "t0.asm"
.include "t1.asm"
.include "t2.asm"

#END
