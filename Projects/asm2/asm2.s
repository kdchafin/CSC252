# Title: ASM2
# Author: Kieran Chafin
# Class: CSC 252
# This asm project completes 5 tasks, all of which utilize loops.
# The loops itterate over strings and arrays of values to produce
# a desired output.

.globl studentMain
studentMain:
    # Allocate stack space and save the frame pointer and return address
    addiu $sp, $sp, -24           		# Allocate space on stack (24 bytes)
    sw $fp, 0($sp)                 		# Save caller's frame pointer
    sw $ra, 4($sp)                 		# Save return address
    addiu $fp, $sp, 20             		# Set up the frame pointer for this function

.data
NEWLINE: 	.asciiz "\n"
NULLSTRING:	.asciiz "\0"
	
FIB_TITLE: 	.asciiz "Fibonacci Numbers:\n"
TWO_SPACE: 	.asciiz "  "
COMMA_SPACE: 	.asciiz ": "
	
ASCENDING: 	.asciiz "Run Check: ASCENDING\n"
DESCENDING: 	.asciiz "Run Check: DESCENDING\n"
NEITHER: 	.asciiz "Run Check: NEITHER\n"
		
WORD_COUNT: 	.asciiz "Word Count: "
	
SWAPPED: 	.asciiz "String successfully swapped!\n"

.text	
	# Task 1: Fibonacci
	# This task prints fibonacci to the nth value, print all values calculated.
	# It uses a loop and a defined value "fib" to determine how far to calculate.
	#
	# prev = 1
	# beforeThat = 0
	# curr = prev + beforeThat
	# printf("%d", curr)
	# beforeThat = curr
	# for (int i = fib; i >= 0; i++) {
	# 	curr = prev + beforeThat
	#	printf("%d", curr)
	#	
	# 	beforeThat = prev
	#	prev = curr
	# }
fibonacciMain:
	# check if fibonacci flag is true
	la 	$t0, fib			# t0 = &fib
	lw 	$s0, 0($t0)			# t0 = fib
	beq 	$s0, $zero, squareMain		# if (fib == 0) skip to square
	
	# incriment itterator and print title
	addi	$s0, $s0, 1			# s0++
	addi    $v0, $zero, 4 			# print "Fibonacci Numbers:\n"
        la      $a0, FIB_TITLE 
        syscall
	
	# define the 3 temp variables for fibonacci
	add 	$t0, $zero, $zero		# t0 = 0
	add 	$t1, $zero, $zero		# t1 = 0
	addi 	$t2, $zero, 1			# t2 = 1
	
	# print block for the 0'th case for fib
	addi    $v0, $zero, 4 			# print("  ")
        la      $a0, TWO_SPACE
        syscall
        addi    $v0, $zero, 1			# print(t0)
        add     $a0, $zero, $t0
        syscall
	addi    $v0, $zero, 4 			# print(", ")
        la      $a0, COMMA_SPACE
        syscall 
        addi	$v0, $zero, 1			# print(t2)
        add	$a0, $zero, $t2
        syscall
        addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE    
        syscall
        
        addi $t0, $zero, 1			# t0++
	
	# loop for fibonacci. t1 and t2 are n-1 and n-2, and t3 is the addition of
	# t1 and t2. loops until t0 == s0
fibonacciLoop:
	# calculates the next fib number
	add 	$t3, $t1, $t2			# t3 = t1 + t2
	
	# print block for fibonacci
        addi    $v0, $zero, 4 			# print("  ")	
        la      $a0, TWO_SPACE
        syscall
        addi    $v0, $zero, 1 			# print(t0)
        add     $a0, $zero, $t0
        syscall
	addi    $v0, $zero, 4 			# print(", ")
        la      $a0, COMMA_SPACE
        syscall 
        addi	$v0, $zero, 1			# print(t3)
        add	$a0, $zero, $t3
        syscall
        addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE    
        syscall
        
        # fibonacci adding of variables t1 and t2
        add 	$t1, $zero, $t2			# t1 = t2
        add 	$t2, $zero, $t3			# t2 = t3 (t1 + t2)
	
	addi 	$t0, $t0, 1			# t0++
	bne 	$s0, $t0, fibonacciLoop		# if (t0 != s0) loop again
	
	# formatting new line
	addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE    
        syscall
	
	# Task 2: Square
	# This task prints a square of "square_size", and fills the square with
	# the "square_fill" char. It uses 2 loops to accomplish this, with the first
	# loop handeling the rows  and the second loop handeling the columns
	#
	# for (int row = 0; row < square_size; row++) {
	#	if ((row == 0) || (row == square_size - 1)) {
	#		lr = '+';
	# 		mid = '-';
	#	}
	#	else {
	#		lr = '|';
	# 		mid = square_fill;
	#	}
	# 	printf("%d", lr);
	#	for (int i = 1; i < square_size-1; i++) {
	#		printf("%c", mid) ;
	#	}
	#	printf("%c\n", lr);
	# }
squareMain:
	# read values and initialize condition registers
	la 	$t0, square			# t0 = &square
	lw 	$s0, 0($t0)			# t0 = square
	beq	$s0, $zero, runCheckMain	# check value of square flag
	
	# set up defining variables
	la	$t0, square_fill		# t0 = &square_fill
	lb	$s1, 0($t0)			# s1 = square_fill
	la	$t0, square_size		# t0 = &square_size
	lw	$s2, 0($t0)			# s2 = square_size
	
	# incrimenter registers for squareLoop1 & squareLoop2
	add 	$s3, $zero, $zero		# row = 0 (itterator)
	addi 	$t3, $s2, -1			# square_size - 1
	
	# outer loop for drawing a square. loops untill s3 == s2.
	# inside it draws each row for the square, where squareMidLoop
	# prints the fill					
squareLoop:
	# base case
	beq	$s3, $s2, endSquare		# row != square_size
	
	# if statement reuqirements
	beq	$s3, $zero, squareIf		# if (row == 0)
	beq 	$s3, $t3, squareIf		# if (row == square_size)
	j 	squareElse			# skip if
	
squareIf:
	# check if we are printing the top or bottom walls of square 
	addi	$t1, $zero, 0x2B		# t1 = +
	addi	$t2, $zero, 0x2D		# t2 = -
	j 	squareContinue			# skip else statement
	
squareElse:
	addi	$t1, $zero, 0x7C		# t1 = |
	add 	$t2, $zero, $s1			# t2 = square_fill
	
squareContinue:
	# print left most character
        addi    $v0, $zero, 11  		# print lr (t1)
        add     $a0, $zero, $t1    	
        syscall
        
        # init midLoop register
        addi	$s4, $zero, 1			# i = 1 (itterator)
        
        # this loop prints the fill char
squareMidLoop:
	# print middle values for square
	beq 	$t3, $zero, squareContinue2	# if (t3 == 0)
	beq	$s4, $t3, squareContinue2	# while i != square_size
	
	addi    $v0, $zero, 11  		# print mid (t2)
        add     $a0, $zero, $t2    
        syscall
        
        # itterate loop
	addi 	$s4, $s4, 1			# i++
	j	squareMidLoop			# loop again
        
squareContinue2:
	# print right most character
        addi    $v0, $zero, 11  		# print lr (t1)
        add     $a0, $zero, $t1    
        syscall
       	addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE    
        syscall
        
        # itterate main loop
	addi 	$s3, $s3, 1			# s3++
	j 	squareLoop			# loop again
	
endSquare:
	# formatting new line
	addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE    
        syscall

	# Task 3: runCheck
	# This task determines if an arrays of integers is ascending, descending, or neither.
	# In the case it is 1 value or all values are th esame, it prints both ascending and descending.
	# It uses a loop to itterate through intArray
	#
	#    if (intArray_len == 0) {
	#        printf("Run Check: ASCENDING\n");
	#        return;
	#    }
	#
	#    int ascending = 1;
	#    int descending = 1;
	#
	#    for (int i = 1; i < intArray_len; i++) {
	#        if (intArray[i] < intArray[i - 1]) {
	#            ascending = 0;
	#        } else if (intArray[i] > intArray[i - 1]) {
	#            descending = 0;
	#        }
	#    }

runCheckMain:
	# check if runCheck is enabled
	la	$t0, runCheck			# t0 = & runCheck
	lw	$t0, 0($t0)			# t0 = runCheck
	beq	$t0, $zero, countWordsMain	# if (runCheck == 0) skip to countWords
	
	# read in array and array length
	la	$t0, intArray_len		# t0 = &intArray
	lw	$s0, 0($t0)			# s0 = intArray_len
	la	$s1, intArray			# s1 = &intArray
	
	# set loop itterator and flags
	addi	$t1, $zero, 1			# t1 = 1 (loop itterator)
	addi	$t2, $zero, 0			# t2 = 0 (ascening flag)
	addi	$t3, $zero, 0			# t3 = 0 (descending flag)
	
	beq 	$s0, $zero, printAscending	# if (s0 == 0)
	
	# this loop is for adjusting the left and right pointers
	# so they itterate over all values of the array
runCheckLoop:
	# loop base case
	beq 	$t1, $s0, printAscending	# if itterator == array size
	lw 	$s2, 0($s1)			# s2 = array[n]
	lw	$s3, 4($s1)			# s3 = array[n+1]
	
checkAscending:
	# check if values are still ascending
	bne	$t2, $zero, checkDescending	# if descending flag != 1
	slt	$t2, $s3, $s2			# flag = s3 < s2
	
checkDescending:
	# check if values are still descending
	bne	$t3, $zero, runCheckContinue	# if ascending flag != 1
	slt	$t3, $s2, $s3			# flag = s2 < s3
	
runCheckContinue:
	# ittterate over the next element of the array and loop
	addi 	$s1, $s1, 4			# shift array by 4
	addi 	$t1, $t1, 1			# itterator++
	j 	runCheckLoop			# loop
	
printAscending:
	bne	$t2, $zero, printDescending	# if ascending flag != 1
	addi    $v0, $zero, 4  			# print("Run Check: ASCENDING\n")
        la      $a0, ASCENDING
        syscall
	
printDescending:
	bne 	$t3, $zero, printNeither	# if descending flag != 1
	
	addi    $v0, $zero, 4  			# print("Run Check: DESCENDING\n")
        la      $a0, DESCENDING
        syscall
	
printNeither:
	and 	$t0, $t2, $t3			# t2 ^ t3 (both flags)
	beq 	$t0, $zero, endRunCheck		# if (t2 ^ t3) == 0, end runCheck
	
	addi    $v0, $zero, 4  			# print("Run Check: NEITHER")
        la      $a0, NEITHER
        syscall
        
endRunCheck:
	# new line for formatting
	addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE
        syscall

	# Task 4: CountWords
	# This task calculates the number of words in a string. It uses whitespace
	# to determine when a word starts and ends, and itterates untill the end string character
	# is found.
	# 
	#    int wordCount = 0;
	#    int inWord = 0;
	#
	#    for (int i = 0; str[i] != '\0'; i++) {
	#        char currentChar = str[i];
	#
	#        if (currentChar == ' ' || currentChar == '\n') {
	#            if (inWord) {
	#                wordCount++;
	#                inWord = 0;
	#        } else {
	#            if (!inWord) {
	#                inWord = 1;
	#            }
	#        }

countWordsMain:
	# chack value of count words flag
	la 	$t0, countWords			# t0 = &countWords
	lw 	$t0, 0($t0)			# t0 = countWords
	beq 	$t0, $zero, revStringMain	# if (!countWords) skip section
	
	# set up required values for the loop
	la	$s0, str			# s0 = &str
	add	$s2, $zero, $zero		# s2 = wordCount (defaults to 0)
	add 	$t1, $zero, $zero		# t1 = char boolean (are we looking at a space or a letter)
	
	# this loop adjusts s0 so it can itterate over all chars in the string
countLoop:
	lb 	$s1, 0($s0)
	
	# check for newline, space, or end of line
	beq	$s1, $zero, printCount		# if (s1 == "\0") end loop
	addi	$t9, $zero, 32			# t9 = " "
	beq 	$s1, $t9, parseSNL		# if (s1 == " ") jump
	addi	$t9, $zero, 10			# t9 = "\n"
	beq 	$s1, $t9, parseSNL		# if (s1 == "\n") jump
	
	beq 	$t1, $zero, addToCount		# if (t1 == 0) jump
	j 	resumeCount			# else skip this letter (this should never execute)
	
parseSNL:
	# skip spaces and newline (and make sure t0 = 0)
	bne 	$t1, $zero, resetT1		# if (t1 == 1) reset t1 to 0
	j 	resumeCount			# else resume

addToCount:
	# increase found words by 1
	addi	$s2, $s2, 1			# s2++
	addi	$t1, $zero, 1			# t1 = 1
	j 	resumeCount			# jump
resetT1:
	# executes on space following a word
	add	$t1, $zero, $zero		#t1 = 0
	
resumeCount:
	# get next char in the string
	addi	$s0, $s0, 1			# s0 = &str + 1
	j countLoop				# loop over next char
	
printCount:
	#print found words after loop finishes
	addi    $v0, $zero, 4  			# print("Word Count: ")
        la      $a0, WORD_COUNT
        syscall
	addi    $v0, $zero, 1  			# print(s1)
        add     $a0, $zero, $s2
        syscall
	addi    $v0, $zero, 4  			# print("\n")
        la      $a0, NEWLINE
        syscall

	# Task 5: Reverse String
	# This task reverses a string. It first finds the length of the string using a loop.
	# It then sets a left and right pointer, which swap with eachother in the second loop.
	#
	#    int length = 0;
	#    while (str[length] != '\0') {
	#        length++;
	#    }
	#
	#    int left = 0;
	#    int right = length - 1;
	#
	#    while (left < right) {
	#        char temp = str[left];
	#        str[left] = str[right];
	#        str[right] = temp;
	#
	#        left++;
	#        right--;
	#    }

revStringMain:
	# check if flag is marked
	la 	$t0, revString			# t0 = &revString
	lw 	$t0, 0($t0)			# t0 = revString
	beq	$t0, $zero, end_if		# if revString == 0, skip to end of code
	
	# conditionals for length loop
	la 	$s0, str			# $s0 = &str
	add	$s2, $zero, $zero		# temp value for length of string
	
	# loop untill end string character is found. this loop sets
	# s2 to the length of the string
revStringLengthLoop:
	lb	$s1, 0($s0)			# s1 = str[0]
	beq	$s1, $zero, reverseStringLoop	# if endValue is found, end loop
	addi	$s2, $s2, 1			# increase string length count
	addi 	$s0, $s0, 1			# get next char
	
	j revStringLengthLoop
	
	# this loop itterates using the length found in the previous loop. it 
	# adjusts the left and right pointers at each end of the string so each char
	# is swapped.
reverseStringLoop:
	# set preconditions for loop
	add	$t1, $zero, $zero		# t1 = 0
	addi 	$s2, $s2, -1			# s2 = s2-1
	add 	$s3, $zero, $zero		# s3 = 0
	
reverseStringLoopMain:
	# base cases for even and odd length strings
	beq 	$s3, $s2, printReverseString	# if (s3 == s2) jump
	slt 	$t3, $s2, $s3			# t3 = s2 < s3
	bne 	$t3, $zero, printReverseString	# if (t3 == 0) jump
	
	# load the element in the string as the left pointers value
	la	$t4, str			# t4 = &str
	add	$t4, $t4, $s3			# t4 = &str[left]
	lb	$s4, 0($t4)			# s4 = str[left]
	# load the element in the string at the right pointers value
	la	$t5, str			# t5 = &str
	add 	$t5, $t5, $s2			# t5 = &str[right]
	lb	$s5, 0($t5)			# s5 = str[right]
	
	# swap the values
	add 	$t9, $zero, $s4			# t9 = s4
	sb 	$s5, 0($t4)			# s5 = t4
	sb	$t9, 0($t5)			# s4 = t9
	
	# incriment and decrement the pointers
	addi 	$s2, $s2, -1			#s2-- (right)
	addi	$s3, $s3, 1			#s3++ (left)
	
	j reverseStringLoopMain
	
printReverseString:
	addi    $v0, $zero, 4  			# print lr (t1)
        la     	$a0, SWAPPED 
        syscall
        
        j end_if

end_if:
        # Restore the return address and frame pointer before returning
        lw      $ra, 4($sp)         		# Load return address from stack
        lw      $fp, 0($sp)         		# Restore caller's frame pointer
        addiu   $sp, $sp, 24     		# Restore the caller's stack pointer
        jr      $ra                 		# Jump to the return address
