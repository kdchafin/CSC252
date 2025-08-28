# Title: Asm4
# Author: Kieran Chafin
# This assembly project uses a structs to hold and retrive turtle
# data. It performs a multitude of tasks to change and update the
# data for certain turtles and stores it back.

# These tasks are:
# 1. Set the turtle Struct
# 2. Turtle Debugger
# 3. Turtle rotater
# 4. Turtle Move
# 5. Turtle Search
# 6. Sort (Not finished)

.data
NORTH:		.asciiz "North\n"
SOUTH:		.asciiz "South\n"
EAST:		.asciiz "East\n"
WEST:		.asciiz "West\n"
TURTLE:		.asciiz	"Turtle \""
POSITION:	.asciiz "\"\n  pos "
DIRECTION:	.asciiz "\n  dir "
DISTANCE:	.asciiz	"  odometer "
COMMA:		.asciiz ","
NEWLINE:	.asciiz	"\n"

.text
# Part 1: Turtle Initialize
# This is the struct for a turtle object, it holds
# 	the turtles name, location in x and y, 
#	the turtles facing direction, and the 
# 	total distance the turtle has traveled

.globl turtle_init
turtle_init:
	addiu 	$sp, $sp, -24		
	sw	$fp, 0($sp)		
	sw 	$ra, 4($sp)		
	addiu	$fp, $sp, 20		
	
	add	$t0, $a0, $zero			# t0 = turtle
	
	add	$t1, $a1, $zero			# t1 = turtle name
	sw	$t1, 4($t0)			# setting turtle's name (byte 4 of the turtle array) to t1
	
	add	$t2, $zero, $zero
	sb	$t2, 0($t0)			# x position = 0
	sb	$t2, 1($t0)			# y position = 0
	sb	$t2, 2($t0)			# direction = 0
	sw	$t2, 8($t0)			# distance = 0

	lw	$ra, 4($sp)
	lw	$fp, 0($sp)
	addiu	$sp, $sp, 24
	jr	$ra

# Part 2: Turtle Debug.
# Prints out all relevant information about the turtle
# Prints as follows:
#Turtle "Blinky"
#  pos 0,0
#  dir North
#  odometer 0

.globl turtle_debug
turtle_debug:
	# prologue
	addiu 	$sp, $sp, -24
	sw	$fp, 0($sp)
	sw 	$ra, 4($sp)
	addiu	$fp, $sp, 20
	
	add	$t0, $zero, $a0			# printf("Turtle ")
	addi	$v0, $zero, 4		
	la	$a0, TURTLE		
	syscall
	lw	$a0, 4($t0)			# printf("%s", turtle.name)
	syscall
	la	$a0, POSITION			# printf("  pos ")
	syscall
	addi	$v0, $zero, 1			# printf("%d", turtle.xPosition)
	lb	$a0, 0($t0)
	syscall
	addi	$v0, $zero, 4			# printf(",")
	la	$a0, COMMA
	syscall
	addi	$v0, $zero, 1			# printf("%d", turtle.yPosition)
	lb	$a0, 1($t0)
	syscall
	addi	$v0, $zero, 4			# printf("%s", turtle.direction)
	la	$a0, DIRECTION
	syscall	
	
	# the following will get and print the turtle direction
	lb	$t1, 2($t0)			# t1 = turtle direction
	bne	$t1, $zero, go_south		# check North (0)	
	la	$a0, NORTH		
	syscall
	j	debug_end
	
go_south:	
	addi	$t2, $zero, 2			# t2 = 2
	bne	$t1, $t2, go_east		# check South (2)
	la	$a0, SOUTH		
	syscall
	j	debug_end

go_east:
	addi	$t2, $zero, 1			# t2 = 1
	bne	$t1, $t2, go_west		# check East (1)
	la	$a0, EAST			
	syscall
	j	debug_end
	
go_west:
	la	$a0, WEST			# print_str(WEST)
	syscall		
	
debug_end:
	la	$a0, DISTANCE			# printf("  odometer ")
	syscall
	addi	$v0, $zero, 1			# printf("%d", turtle.distance)
	lw	$a0, 8($t0)		
	syscall
	
	addi	$v0, $zero, 4
	la	$a0, NEWLINE			# print_char(\n)
	syscall
	syscall
	
	# epilogue
	lw	$ra, 4($sp)	
	lw	$fp, 0($sp)			
	addiu	$sp, $sp, 24		
	jr	$ra	
	
# Part 3: Turn Left and Right
# The following two functions turn the turtle left and right by
# adding or subtracting 1 to its direction variable in the
# turtle struct

.globl turtle_turnLeft
turtle_turnLeft:
	# prologue
	addiu 	$sp, $sp, -24	
	sw	$fp, 0($sp)			
	sw 	$ra, 4($sp)			
	addiu	$fp, $sp, 20		
	
	lb 	$t0, 2($a0)			# load current direction
	addi 	$t0, $t0, -1			# rotate to the left by 1
	
	addi 	$t3, $zero, 3			# t3 = 3
	
	slt 	$t1, $t0, $zero			# if direction < 0
	slt 	$t2, $t3, $t0			# if direction > 3
	bne 	$t1, $zero, set_high		# set to 3
	bne 	$t2, $zero, set_low		# set to 0
	j 	end_left
	
set_high:
	addi	$t0, $zero, 3			# set direction to 3
	j	end_left
	
set_low:
	add	$t0, $zero, $zero		# set direction to 0
	
end_left:
	sb	$t0, 2($a0)			# save new direction
	
	# epilogue
	lw	$ra, 4($sp)			
	lw	$fp, 0($sp)			
	addiu	$sp, $sp, 24		
	jr	$ra

.globl turtle_turnRight
turtle_turnRight:
	# prologue
	addiu 	$sp, $sp, -24		
	sw	$fp, 0($sp)			
	sw 	$ra, 4($sp)			
	addiu	$fp, $sp, 20		
	
	lb	$t0, 2($a0)			# load direction
	addi	$t0, $t0, 1			# rotate direction right 

	addi 	$t3, $zero, 3			# t3 = 3
	
	slt 	$t1, $t0, $zero			# if direction < 0
	slt 	$t2, $t3, $t0			# if direction > 3
	bne 	$t1, $zero, set_highR		# set direction to 3
	bne 	$t2, $zero, set_lowR		# set direction to 0
	j	end_right
	
set_highR:
	addi	$t0, $zero, 3			# set direction to 3
	j	end_right
	
set_lowR:
	add	$t0, $zero, $zero		# set direction to 0
	
end_right:
	sb	$t0, 2($a0)			# save new direction
	
	# epilogue
	lw	$ra, 4($sp)			
	lw	$fp, 0($sp)			
	addiu	$sp, $sp, 24		
	jr	$ra				

# Part 4: Turtle Move
# This function moves the turtle in its current facing direction
# Some C code to explain:

.globl turtle_move
turtle_move:
	# prologue
	addiu 	$sp, $sp, -24
	sw	$fp, 0($sp)		
	sw 	$ra, 4($sp)			
	addiu	$fp, $sp, 20		
	
	# load turtle data
	lb	$t0, 2($a0)			# t0 = direction
	lb	$t1, 0($a0)			# t1 = x position
	lb	$t2, 1($a0)			# t2 = y position
	
	# check direction
	bne	$t0, $zero, move_south 		# check if facing north
	add	$t2, $t2, $a1			# y + distance
	
	# if turtle has moved off the board positive
	addi	$t3, $zero, 11			# t3 = 11
	slt	$t3, $t2, $t3			# if (y < 11), t3 = 1
	bne	$t3, $zero, north_negative	# if y is not greater than 10, check negative bounds
	
	# clamp y position to 10
	addi	$t2, $zero, 	10		# turtle.yPosition = 10
	j	get_distance
	
north_negative:
	# if turtle has moved off the board negative
	addi	$t3, $zero,	-11		# t3 = -11
	slt 	$t3, $t3,	$t2		# if (y > -11), t3 = 1
	bne	$t3, $zero,	get_distance	# if y is not less than -10, then the move is valid
	
	# clamp y position position to -10
	addi	$t2, $zero,	-10		# turtle.yPosition = -10
	j	get_distance
	
move_south:
	# check direction
	addi	$t3, $zero,	2		# check if facing south
	bne	$t0, $t3,	move_east	# else leave and check east
	
	# if turtle has moved off the board positive
	sub	$t2, $t2,	$a1		# y position - distance
	addi	$t3, $zero,	11		# t3 = 11
	slt	$t3, $t2,	$t3		# if ( y < 11 ), t3 = 1
	bne	$t3, $zero,	south_negative	# if y is not greater than 10, then check negative
	
	# clamp y position to 10
	addi	$t2, $zero,	10		# turtle.yPosition = 10
	j 	get_distance
	
south_negative:
	# if turtle has moved off the board negative
	addi 	$t3, $zero,	-11		# t3 = -11
	slt	$t3, $t3,	$t2		# if (y > -11), t3 = 11
	bne	$t3, $zero,	get_distance	# if y is not less than -10, then the move is valid
	
	# clamp y position to 10
	addi	$t2, $zero,	-10		# y = -10
	j 	get_distance
	
move_east:
	# check direction
	addi	$t3, $zero,	1		# t3 = 1
	bne	$t0, $t3,	move_west	# check if facing east, else turtle must be facing west
	
	# if turtle has moved off the board positive
	add	$t1, $t1,	$a1		# x position + distance
	addi	$t3, $zero,	11		# t3 = 11
	slt	$t3, $t1,	$t3		# if (x < 11), t3 = 1
	bne	$t3, $zero,	east_negative	# if xPosition is not greater than 10, then check negative
	
	# clamp x position to 10
	addi	$t1, $zero,	10		# x = 10
	j 	get_distance
	
east_negative:
	# if turtle has moved off the board negative
	addi 	$t3, $zero,	-11		# t3 = -11
	slt	$t3, $t3,	$t1		# if (y > -11), t3 = 11
	bne	$t3, $zero,	get_distance	# if y position  is not less than -10, then the move is valid
	
	# clamp x position to -10
	addi	$t1, $zero,	-10		# x = -10
	j 	get_distance

move_west:
	# if turtle has moved off the board positive
	sub	$t1, $t1,	$a1		# x position - distance
	addi	$t3, $zero,	11		# t3 = 11
	slt	$t3, $t1,	$t3		# if (x < 11), t3 = 1
	bne	$t3, $zero,	west_negative	# if xPosition is not greater than 10, then check negative
	
	# clamp x position to 10
	addi	$t1, $zero,	10		# x = 10
	j 	get_distance
	
west_negative:
	# if turtle has moved off the board negative
	addi 	$t3, $zero,	-11		# t3 = -11
	slt	$t3, $t3,	$t1		# if (y > -11), t3 = 11
	bne	$t3, $zero,	get_distance	# if x position is not less than -10, then the move is valid
	
	# clamp y position to -10
	addi	$t1, $zero,	-10		# x = -10
	j 	get_distance
	
get_distance:
	# load turtles x and y positions
	lb	$t4, 0($a0)			# t4 = x position
	lb	$t5, 1($a0)			# t5 = y position
	
	# add x distance and save
	add	$t4, $zero, 	$t1		# x = t1
	sb	$t4, 0($a0)			# x position = t4
	
	# add y distance and save
	add	$t5, $zero,	$t2		# y = t2
	sb	$t5, 1($a0)			# y position = t5
	
	lw	$t6, 8($a0)			# t6 = distance
	slt	$t3, $zero,	$a1		# if (0 < distance)
	beq	$t3, $zero,	neg_distance	# if (dist > 0), add neg to odo
	add	$t6, $t6,	$a1		# distance = distance + t6
	j 	DONE_4
	
neg_distance:
	sub	$t6, $t6,	$a1		# total distance = -(-t6)
DONE_4:
	sw	$t6, 8($a0)			# set distance
	
	# epilogue
	lw	$ra, 4($sp)			
	lw	$fp, 0($sp)			
	addiu	$sp, $sp, 	24		
	jr	$ra				
	
# Task 5: Turtle Search
# Search for a turtle by name. This function loops through
# all turtle objects until the name matches, then gets the data
# for that turtle

.globl turtle_searchName
turtle_searchName:
	# prologue
	addiu 	$sp, $sp, -24		
	sw	$fp, 0($sp)			
	sw 	$ra, 4($sp)			
	addiu	$fp, $sp, 20		
	
	# set up variables for looping
	addi	$t3, $zero,-1			# t3 = -1
	addi	$t0, $zero, 0			# i = 0
	add 	$t1, $zero, $a0			# t1 = &arr
#loop through all turtle objects
loop1:	
	# base case 
	slt	$t2, $t0, $a1		
	beq	$t2, $zero, end_loop		# if (itterator < arrLen), jump
	
	add	$t2, $zero, $t1			# get next turtle in array
	lw	$t2, 4($t2)			# t2 = turtle name
	
	# move stack pointer to save data
	addiu	$sp, $sp, -20
	
	# save registers before function call
	sw	$a1, 16($sp)		 
	sw	$t0, 12($sp)		
	sw	$t1, 8($sp)		
	sw	$t2, 4($sp)		
	sw	$t3, 0($sp)		
	
	# set arugments 
	add	$a0, $zero,	$t2		# a0 = current turtle name
	add	$a1, $zero,	$a2
	
	# jump
	jal	strcmp				# strcmp(turtle.name, needle)
	
	# load back registers from the stack
	lw	$t3, 0($sp)			
	lw	$t2, 4($sp)			
	lw	$t1, 8($sp)			
	lw	$t0, 12($sp)			
	lw	$a1, 16($sp)		
	
	# move pointer back	
	addiu	$sp, $sp, 	20		
	bne	$v0, $zero,	next_turtle	# if ( turtle name == desired name)
	add	$t3, $zero,	$t0		# t3 = itterator
	j 	end_loop
	
next_turtle:
	addi	$t0, $t0, 	1		# i++
	addi	$t1, $t1,	12		# add 12 for next turtle since turtle objects use 12 bytes in stack
	j	loop1
	
end_loop:
	add	$v0, $zero,	$t3		# set output register
	
	# epilogue
	lw	$ra, 4($sp)			# loading caller's return address
	lw	$fp, 0($sp)			# loading caller's frame pointer
	addiu	$sp, $sp, 	24		# moving stack pointer up 6 slots in the stack
	jr	$ra				# returning to caller function
	
# Task 6: Turtle Sort

.globl turtle_sortByX_indirect
turtle_sortByX_indirect:
	# Prologue
	addiu 	$sp, $sp, 	-24		
	sw	$fp, 0($sp)			
	sw 	$ra, 4($sp)			
	addiu	$fp, $sp, 	20		

	# Epilogue
	lw	$ra, 4($sp)			
	lw	$fp, 0($sp)			
	addiu	$sp, $sp, 	24		
	jr	$ra				
	
	
