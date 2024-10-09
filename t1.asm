# file t1.asm
    .data
STRING_T1: .asciiz "\nSecond Task - "
    .text
t1: 
	li $t0,0
repeat1:
	la $a0, STRING_T1
	li $v0, 4
	syscall
	
	move $a0,$t0
	li $v0, 1
	syscall
	
	addi $t0,$t0,1
	b repeat1
