# this is a simple example on how to use interrupts to receive chars from a serial terminal keyboard
# and echoing them to the terminal screen. Note that it does not support output buffering as it should in 
# a real case. You may think of how it could be done.

.data
RCR: .word 0xffff0000
RDR: .word 0xffff0004

TCR: .word 0xffff0008
TDR: .word 0xffff000c
ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00010000
COMMA: .asciiz ", \n"
msg: .asciiz "Memory mapped keyboard and terminal screen example\n for AC classes.\n"
counter: .word 0
waitcount: .word 100000
.text

main:
	jal int_enable
		
	la   $a0, msg  # address of string to print
  	li   $v0, 4    # Print String service
  	syscall
  	
  	# now it is going to enter a forever loop.
idle_loop:
wait_loop: # the first loop is a busywait delay loop
	lw $t1,waitcount
	addi $t1,$t1,-1
	sw $t1, waitcount
	bgtz $t1,wait_loop
	li $t1, 100000
	sw $t1, waitcount
	
	lw $t1, counter
	addi $t1,$t1,1
	sw $t1,counter
	move $a0,$t1
	li $v0,1
	syscall
	la $a0,COMMA
	li $v0,4
	syscall
	b idle_loop
	
int_enable:
	mfc0 $t0, $12
	lw $t1, ALL_INT_MASK
	not $t1,$t1
	and $t0,$t0,$t1 # disable all int 
	lw $t1, KBD_INT_MASK	
	or $t0,$t0,$t1
	mtc0 $t0,$12
	
	# now enable interrupts on the KBD
	lw $t0,RCR
	li $t1, 0x00000002
	sw $t1 0($t0)
	jr $ra
	
	
	.ktext 0x80000180
	#save every used register as needed
	move $k0,$at
	sw $k0, save_at
	
	sw $t1, save_t1
	sw $t2, save_t2
	sw $s1, save_s1
	sw $s2, save_s2
	sw $s3, save_s3
	sw $s4, save_s4
	sw $a0, save_a0
	sw $v0, save_v0
	
	mfc0 $k0,$13 # get cause register 
	srl $t1,$k0,2
	andi $t1,$t1,0x1f # extract bits 2-6
	bne $t1,6,ok_pc
#	move $a0,$t1
#	li $v0,1
#	syscall
ok_pc:
	bnez $t1, non_int
		
	andi $t2,$k0,0x00000100  # is bit 8 set?
	bnez $t2, receive
	andi $t2,$t1,0x00000200 # is bit 9 set?
	bnez $t2, transmit
	b iend

receive:
	lw $s1, RCR
	lw $s2, RDR
	
	lw $t1,0($s1) # read the RCRr
	beqz $t1,iend # if not set exit
	lw $t2,0($s2) # read char
transmit:
	lw $s3, TCR
	lw $s4, TDR 

	lw $t1,0($s3)
	beqz $t1,iend # cannot transmit
	sw $t2,0($s4) # write char to transmit register
	b iend

non_int:
	mfc0 $k0,$14
	addiu $k0,$k0,4
	mtc0 $k0,$14
	
iend:
	lw $t1, save_t1
	lw $t2, save_t2
	lw $s1, save_s1
	lw $s2, save_s2
	lw $s3, save_s3
	lw $s4, save_s4
	lw $a0, save_a0
	lw $v0, save_v0
	
	lw $k0, save_at
	move $at,$k0
	mtc0 $zero,$13
	mfc0 $k0,$12
	andi $k0, 0xfffd
	ori $k0,0x0001
	mtc0 $k0,$12
	eret
	
	.kdata 
save_t1: .word
save_t2: .word
save_s1: .word
save_s2: .word
save_s3: .word
save_s4: .word
save_a0: .word
save_v0: .word
save_at: .word
