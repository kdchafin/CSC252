# Title: Asm3
# Author: Kieran Chafin
# This assembly project uses pro and epilogues for creating fucntions. It also sets up a fucntion call
# in task 5. These tasks are:
# 1. String length
# 2. Greatest Common Factor (recursive)
# 3. Bottles
# 4. Longest ascending in an array of ints
# 5. Rotate Array of 6

.data 
STRLEN:		.asciiz ""
BOTTLES1: 	.asciiz " bottles of "
BOTTLES2: 	.asciiz " on the wall, "
BOTTLES3:	.asciiz "!\n"
BOTTLES4:	.asciiz "Take one down, pass it around, "
BOTTLES5:	.asciiz " on the wall.\n\n"
BOTTLES6:	.asciiz "No more bottles of "
BOTTLES7:	.asciiz " on the wall!\n\n"

# 1. String Length - return the length of a string passed into the function
# Return the int value back to function call
.text
.globl strlen
strlen:
	addiu 	$sp, $sp, -24		# default the stack pointer
	sw	$fp, 0($sp)		# store frame
	sw	$ra, 4($sp)		# store ra
	addiu	$fp, $sp, 20		# move stack pointer 5 up
	
	add	$t1, $zero, $zero 	# loop iterator
	add 	$t2, $zero, $a0		# t3 = string
	
# loop over all chars in the string	
strlen_loop:
	lb	$t0, 0($t2)		# t0 = t3
	beq	$t0, $zero, strlen_return	# if (t0 == t2), return
	
	addi 	$t2, $t2, 1		# t0 = 1			
	
	addi	$t1, $t1, 1		# t1 = 1
	j strlen_loop			# loop
	
strlen_return:
	add	$v0, $zero, $t1		# set return variable to t1
	
	lw 	$ra, 4($sp)		# load back return address
	lw	$fp, 0($sp)		# load back frame pointer
	addiu	$sp, $sp, 24		# move stack pointer +24
	jr	$ra			# return to function call
	
# 2. Greatest Common Factor 
# calculate the gcf of two numbers passed in
# then return the gcf as an int

.globl gcf
gcf:	
	addiu 	$sp, $sp, -24		# default the stack pointer
	sw	$fp, 0($sp)		# store frame
	sw	$ra, 4($sp)		# store ra
	addiu	$fp, $sp, 20		# move stack pointer 5 up
	
	add	$t1, $zero, $a0		# t1 = a
	add 	$t2, $zero, $a1		# t2 = b
	
	#if (a < b) do {a, b = b,a
	slt 	$t0, $t2, $t1		# if a < b, go to if2
	addi	$t9, $zero, 1
	beq	$t0, $t9, gcf_if2	
	
	add	$t0, $zero, $t1		# temp = a
	add	$t1, $zero, $t2		# a = b
	add 	$t2, $zero, $t0		# b = temp
	
	
gcf_if2:
	#if (b == 1) return 1
	addi	$t0, $zero, 1		# t0 = 1
	bne	$t2, $t0, gcf_if3	# if (b != 1)
	
	addi	$v0, $zero, 1		# v0 = 1
	j	gcf_return		# return
	
gcf_if3:
	# if (a % b == 0) return b
	div 	$t1, $t2		# a / b
	mfhi	$t0			# t0 = a % b
	bne 	$t0, $zero, gcf_else	# if (a % b != 0)
	
	add	$v0, $zero, $t2		# v0 = b
	j 	gcf_return		# return
	
gcf_else:
	# else recurse on gcf
	div 	$t1, $t2		# a / b	
	mfhi	$t0			# t0 = a % b
	
	# store save registers
	add 	$a0, $zero, $t2		# store b in a0
	add	$a1, $zero, $t0		# store a % b in a1
	jal 	gcf
	
gcf_return:
	lw 	$fp, 0($sp)		# load frame pointer
	lw	$ra, 4($sp)		# load stack pointer
	addiu	$sp, $sp, 24		# shift stack 24
	jr	$ra			# return to function call
	
# 3. Bottles
# Takes 2 params, a count, and a string.
# Returns a formatted string "%d bottles of $s on the wall, %d bottles of %s"

# reference for .data section	
# BOTTLES1: 	.asciiz " bottles of "
# BOTTLES2: 	.asciiz " on the wall, "
# BOTTLES3	.asciiz "!\n"
# BOTTLES4	.asciiz "Take one down, pass it around, "
# BOTTLES5	.asciiz " on the wall.\n"
# BOTTLES6:	.asciiz "No more bottles of "
# BOTTLES7:	.asciiz " on the wall!\n\n"

.globl bottles
 bottles:
 	addiu 	$sp, $sp, -24		# default the stack pointer
	sw	$fp, 0($sp)		# store frame
	sw	$ra, 4($sp)		# store ra
	addiu	$fp, $sp, 20		# move stack pointer 5 up
	
	add	$t1, $zero, $a0		# t1 = count

# loop so all bottle counts print untill 0
bottles_loop:
	beq	$t1, $zero, btl_return	# if (count == 0) exit loop
	
	addi 	$v0, $zero, 1		# print(%d)
	add	$a0, $zero, $t1
	syscall
	
	addi	$v0, $zero, 4		# print(" bottles of ")
	la 	$a0, BOTTLES1
	syscall
	
	addi 	$v0, $zero, 4		# print("%s")
	add 	$a0, $zero, $a1
	syscall
	
	addi	$v0, $zero, 4		# print(" on the wall, ")
	la 	$a0, BOTTLES2
	syscall
	
	addi 	$v0, $zero, 1		# print(%d)
	add	$a0, $zero, $t1
	syscall
	
	addi	$v0, $zero, 4		# print(" bottles of ")
	la 	$a0, BOTTLES1
	syscall
	
	addi 	$v0, $zero, 4		# print("%s")
	add 	$a0, $zero, $a1
	syscall
	
	addi	$v0, $zero, 4		# print("!\n")
	la 	$a0, BOTTLES3
	syscall
	
	addi	$v0, $zero, 4		# print("Take one down, pass it around, ")
	la 	$a0, BOTTLES4
	syscall
	
	addi 	$t1, $t1, -1		# count--
	
	addi 	$v0, $zero, 1		# print(%d)
	add	$a0, $zero, $t1
	syscall
	
	addi	$v0, $zero, 4		# print(" bottles of ")
	la 	$a0, BOTTLES1
	syscall
	
	addi 	$v0, $zero, 4		# print("%s")
	add 	$a0, $zero, $a1
	syscall
	
	addi	$v0, $zero, 4		# print(" bottles of ")
	la 	$a0, BOTTLES5
	syscall
	
	j	bottles_loop		# loop
	
btl_return:
	addi	$v0, $zero, 4		# print("No more bottles of ")
	la 	$a0, BOTTLES6
	syscall
	addi 	$v0, $zero, 4		# print("%s")
	add 	$a0, $zero, $a1
	syscall
	addi	$v0, $zero, 4		# print(" on the wall\n\n")
	la 	$a0, BOTTLES7
	syscall
	
	lw 	$ra, 4($sp)		# load return adddress
	lw	$fp, 0($sp)		# load frame pointer
	addiu	$sp, $sp, 24		# shift stack pointer
	jr	$ra			# return to function call
	
# 4. Longest Sorted
# returns the length of the longest chain of numbers in increasing order
# of a array of numbers
	

.globl longestSorted
longestSorted: 

	addiu 	$sp, $sp, -24		# shift stack -24
	sw	$fp, 0($sp)		# store frame
	sw 	$ra, 4($sp)		# store return address
	addi 	$fp, $sp, 20		# shift 20
	
	add	$t1, $zero, $a0		# array
	add	$t2, $zero, $a1		# array length
	add	$t3, $zero, $zero	# loop iterator
	addi	$t4, $zero, 1		# curr longest
	add	$t5, $zero, $zero	# known longest

	beq 	$t2, $zero, lns_return	# if array is empty
	
	addi	$t5, $zero, 1		# longest = 0
	beq 	$t2, $t4, lns_return	# if array is 1
	
	addi 	$t2, $t2, -1

# while ints still in array
longestSorted_loop:
	beq	$t3, $t2, lns_return	# if (t3 == t2) exit loop
	
	# get i and i+1 from array
	lw	$t8, 0($t1)		# t9 = array[i]
	lw 	$t9, 4($t1)		# t8 = array[i+1]
	slt 	$t7, $t9, $t8		# t7 = t9 < t8
	
	addi	$t6, $zero, 1		# t6 = 1
	beq 	$t7, $t6, reset		# if (t7 == 0), reset
	addi 	$t4, $t4, 1		# t4++
	j 	check_longest
	
reset:	
	# if t9 >= t8, reset curr longest and loop
	addi 	$t4, $zero, 1		# t4 = 0
	j	loop_again
	
check_longest:
	# check if curr longest >= known longest 
	slt	$t7, $t4, $t5		# t7 = t4 < t5 "if our current longest is less than our known longest"
	beq 	$t7, $zero, new_longest	# t7 == 0
	j 	loop_again
	
new_longest:
	# set longest
	add 	$t5, $zero, $t4		# t5 = t4 "set new longest"
	
loop_again:
	# incriment array and loop iterator
	addi	$t1, $t1, 4		# t3 += 4
	addi 	$t3, $t3, 1		# t1++
	j 	longestSorted_loop

lns_return:
	# load longest found
	add 	$v0, $zero, $t5		# load longest found

	lw 	$ra, 4($sp)		# load return address
	lw	$fp, 0($sp)		# load frame 
	addiu	$sp, $sp, 24		# shift frame 24
	jr	$ra			# jump to fucntion call
	
# 5. Rotate an array of ints, perfomring the function util during every rotation
# Add the returned value from every function and return it
.globl rotate
rotate:
	addiu 	$sp, $sp, -36		# Shift 36 to account for 7 params
	sw	$fp, 0($sp)		# store frame pointer
	sw 	$ra, 4($sp)		# store return address
	addi 	$fp, $sp, 32		# shift fram 32
	
	# shift stack -28 and load s registers
	addiu 	$sp, $sp, -28		# shift stack 28	
	sw	$s0, 0($sp)		# s0 = count
	sw	$s1, 4($sp)		# s1 = a
	sw	$s2, 8($sp)		# s2 = b
	sw	$s3, 12($sp)		# s3 = c
	sw	$s4, 16($sp)		# s4 = d
	sw	$s5, 20($sp)		# s5 = e
	sw	$s6, 24($sp)		# s6 = f
	
	add 	$t0, $zero, $zero	# retval
	add 	$t1, $zero, $zero 	# loop iterator
	
	# set the s registers before for loop call
	add 	$s0, $zero, $a0		# s0 =  count
	add	$s1, $zero, $a1 	# s1 = a
	add	$s2, $zero, $a2		# s2 = b
	add	$s3, $zero, $a3 	# s3 = c
	
	#store extra 3 (start at 52 becuase we shifted (24 + 28))
	lw	$s4, 52($sp)		# s4 = d
	lw	$s5, 56($sp)		# s5 = e
	lw	$s6, 60($sp)		# s6 = f
	
# looping till count == 0, rotating every loop
rotate_loop:
	slt	$t2, $t1, $s0		# t2 = i < count	
	beq	$t2, $zero, rot_return	# if (t2 == 0) exit loop
	
	# save s register before util call
	add 	$a0, $zero, $s1		# a0 = a
	add 	$a1, $zero, $s2		# a1 = b
	add 	$a2, $zero, $s3		# a2 = c
	add 	$a3, $zero, $s4		# a3 = d
	
	# shift stack pointer to allocate room for 2 more params
	addiu 	$sp, $sp, -8
	sw 	$t0, 0($sp)		# retval
	sw	$t1, 4($sp)		# iterator
	
	# store 2 other params in stack
	sw 	$s5, -8($sp)		# s5 = e
	sw 	$s6, -4($sp)		# s6 = f
	jal 	util			# function call util
	
	# load back from util stack
	lw	$t1, 4($sp)		# set retval back
	lw 	$t0, 0($sp)		# set iterator back
	addiu 	$sp, $sp, 8		# shift frame back to a-f locatons
	
	# load a-f back to s registers
	add 	$t9, $zero, $s1		
	add 	$s1, $zero, $s2
	add 	$s2, $zero, $s3
	add 	$s3, $zero, $s4
	add 	$s4, $zero, $s5
	add 	$s5, $zero, $s6
	add 	$s6, $zero, $t9
	
	add 	$t0, $t0, $v0 		# retval += retval
	
	addi 	$t1, $t1, 1		# incriment itterator and loop
	j 	rotate_loop
	
rot_return:
	
	# set return value to retval
	add 	$v0, $zero, $t0
	
	# load back s values from before this function
	lw	$s0, 0($sp)			
	lw	$s1, 4($sp)			
	lw	$s2, 8($sp)			
	lw	$s3, 12($sp)			
	lw	$s4, 16($sp)			
	lw	$s5, 20($sp)			
	lw	$s6, 24($sp)
	addiu	$sp, $sp, 28		# shift back to frame address
	
	lw 	$ra, 4($sp)		# load return address
	lw	$fp, 0($sp)		# load the fram pointer
	addiu	$sp, $sp, 36		# shift 36 to beginning to stack 
	jr	$ra			# return to function call
