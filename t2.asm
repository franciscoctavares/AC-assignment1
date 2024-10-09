# file t2.asm
    .data
STRING_T2: .asciiz "\nThird Task - "

    .text
t2: 
	li $t0,0
repeat2:
	la $a0, STRING_T2
	li $v0, 4
	syscall
	
	move $a0,$t0
	li $v0, 1
	syscall
	
	addi $t0,$t0,1
	b repeat2
