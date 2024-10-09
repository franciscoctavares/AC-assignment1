# file t0.asm
    .data
STRING_T0: .asciiz "\nFirst Task - "
    .text
t0: 
	li $t0,0
repeat0:
	la $a0, STRING_T0
	li $v0, 4
	syscall
	
	move $a0,$t0
	li $v0, 1
	syscall
	
	addi $t0,$t0,1
	b repeat0
