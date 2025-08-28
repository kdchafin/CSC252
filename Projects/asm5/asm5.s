# Title: Asm5
# Author: Kieran Chafin
# This assembly project uses a structs to hold and retrive turtle
# data. It performs a multitude of tasks to change and update the
# data for certain turtles and stores it back.

.data
newline:        .asciiz "\n"
header_dash:    .asciiz "----------------\n"
closer_dash:    .asciiz "\n----------------\n"
colon_space:    .asciiz ": "
other_msg:      .asciiz "<other>: "

.text
.globl countLetters
#Task 1: Count Letters
# Loops over the chars in a string, counting each letter.
# it then prints out the number of each char found.
# it is not case sensetive, and any other chars found not a-z
# are counted in the "other" field. This includes newlines

#   void countLetters(char *str)
#    {
#        int letters[26];    // this function must fill these with zeroes
#        int other    = 0;
#
#        printf("----------------\n%s\n----------------\n", str);
#
#        char *cur = str;
#        while (*cur != '\0')
#        {
#            if (*cur >= 'a' && *cur <= 'z')
#                letters[*cur-'a']++;
#            else if (*cur >= 'A' && *cur <= 'Z')
#                letters[*cur-'A']++;
#            else
#                other++;
#
#            cur++;
#        }
#
#        for (int i=0; i<26; i++)
#            printf("%c: %d\n", 'a'+i, letters[i]);
#        printf("<other>: %d\n", other);
#    }   

countLetters:
    	# prologue
    	addiu 	$sp, $sp, -128              	
    	sw    	$ra, 4($sp)                 	
    	sw    	$fp, 0($sp)              
    	addiu 	$fp, $sp, 124
	
    	# set t0 = string (param 1)
    	add 	$t0, $a0, $zero
    	
    	# print header
    	la   	$a0, header_dash             	# print "----------------\n"
    	addi 	$v0, $zero, 4                                             
    	syscall
    	add 	$a0, $t0, $zero                 # print "string"
    	addi 	$v0, $zero, 4
    	syscall
    	la   	$a0, closer_dash             	# print "\n----------------\n"
    	addi 	$v0, $zero, 4
    	syscall
    	
    	# initalize value registers
    	addi 	$t1, $zero, 26               	# t1 = a (26)
    	add 	$t2, $zero, $zero               # t2 = i = 0
    	add 	$t3, $zero, $zero               # t3 = other = 0
    	addi 	$t4, $sp, 8                  	# t4 = stack pointer

# initalizes the function with correct letters=
init_zeros:
	# check if i is a valid letter
    	slt 	$t5, $t2, $t1  			# t5 = 0 < 26
    	beq 	$t5, $zero, main_loop		# if (t5 == 0) jump
	
	# if not valid, increment and loop again
    	sw   	$zero, 0($t4)  			# store zeros for each letter           
    	addi 	$t4, $t4, 4             	# move pointer
    	addi 	$t2, $t2, 1             	# increment i
    	j    	init_zeros

# check each char in the string
main_loop:
    	lb  	$t5, 0($t0)             	# t5 = string at index 0
    	beq 	$t5, $zero, print_counts    	# check for end of line

check_upper:
	# check if letter is an uppercase varient
    	slti 	$t6, $t5, 65                 	# loweer bound is 65 (A)
    	bne  	$t6, $zero, count_other      	# if smaller, must be other
    	
    	# check upper bound
    	slti 	$t6, $t5, 91                 	# upper bound is 91 (Z)
    	beq  	$t6, $zero, check_lower      	# if bigger, check lower case
    	
    	# else, must be uppercase
    	j 	upper

check_lower:
	# check is letter is lowercase varient
    	slti 	$t6, $t5, 97                 	# lower bound is 97 (a)
    	bne  	$t6, $zero, count_other      	# if lower (between 91-97) must be other
    	
    	# check upper bound
    	slti 	$t6, $t5, 123               	# if letter is bigger than z
    	beq  	$t6, $zero, count_other      	# if larger, must be other

lower:
	# increment the letter associated
    	sll  	$t6, $t5, 2                  	# t6 *= 4
    	
    	# reset sp
    	addi 	$t6, $t6, -380               	# a = 8, z = 108
    	
    	# increment letter 
    	add 	$t7, $sp, $zero                 # t7 = sp
    	add  	$t7, $t7, $t6                	# t7 = offset  char val
    	
    	lw   	$t8, 0($t7)                  	# t8 = char val
    	addi 	$t8, $t8, 1                  	# char val ++
    	sw   	$t8, 0($t7)                  	# store new char val
    	
    	j 	next_char

upper:
	# increment the letter associated
    	sll  	$t6, $t5, 2                  	# t6 *= 4
    	
    	# reset sp
    	addi 	$t6, $t6, -252               	# a = 8, z = 108
    	
    	# increment letter
    	add 	$t7, $sp, $zero                 # t7 = sp
    	add  	$t7, $t7, $t6            
    	    	
    	lw   	$t8, 0($t7)                  	# t8 = char val
    	addi 	$t8, $t8, 1                  	# char val ++
    	sw   	$t8, 0($t7)                  	# store new char val
    	j 	next_char
    
# if its neither upper or lower, then increment other
count_other:
    	addi 	$t3, $t3, 1                  	# other++
	
next_char:
	#retrieve next char from the string 
    	addi 	$t0, $t0, 1			# increment 1 for next byte							
    	j 	main_loop

print_counts:
	# init values for printing
    	addi 	$t5, $zero, 26               	# t5 = last char (26)
    	add	$t6, $zero, $zero               	# t6 = incrementer
    	addi 	$t7, $sp, 8                  	# t7 = sp

print_loop:
	#only want to print ascii chars a-z
    	slt 	$t8, $t6, $t5             
    	beq 	$t8, $zero, print_end      	# if (i >= 26), print_other
	
	# print
    	addi 	$a0, $t6, 97                 	# char[i]
    	addi 	$v0, $zero, 11
    	syscall 
    	la 	$a0, colon_space  		# print (": ") 
    	addi 	$v0, $zero, 4              
    	syscall
    	
    	lw 	$t9, 0($t7)                    	# load char count
    	add 	$a0, $t9, $zero             
    	addi 	$v0, $zero, 1                	# print ("%d", count)
    	syscall
    	
    	addi 	$a0, $zero, 10               	# print "\n"
    	addi 	$v0, $zero, 11               	# print char syscall
    	syscall
	
	# loop to next char
    	addi 	$t6, $t6, 1                  	# i++
    	addi 	$t7, $t7, 4                  	# sp + 4
    	j print_loop

print_end:
	# print other after all chars
    	la   	$a0, other_msg               	# print "<other>: "
    	addi 	$v0, $zero, 4
    	syscall
    	add 	$a0, $t3, $zero			# print other count
    	addi 	$v0, $zero, 1
    	syscall
    	la 	$a0, newline               	# print "\n"
    	addi 	$v0, $zero, 4               	
    	syscall

    	# epilogue
    	lw    	$ra, 4($sp)              
    	lw    	$fp, 0($sp)                 
    	addiu 	$sp, $sp, 128               
    	jr    	$ra
    	
# Task 2, Subs Cipher
# This function encrypts a given string

# void subsCipher(char [] str, char [] map)
#    {
#        // NOTE: len is one more than the length of the string; it includes
#        //       an extra character for the null terminator.
#        int len = strlen(str)+1;
#
#        int len_roundUp = (len+3) & ~0x3;
#        char dup[len_roundUp];    // not legal in C, typically.  See spec.
#
#        for (int i=0; i<len-1; i++)
#            dup[i] = map[str[i]];
#        dup[len-1] = '\0';
#
#        printSubstitutedString(dup);
#    }
.globl subsCipher
subsCipher:
	# prologue
        addiu	$sp, $sp, -272         		
        sw      $ra, 268($sp)          		
        sw      $s0, 264($sp)          		# Save $s0 (str)
        sw      $s1, 260($sp)          		# Save $s1 (map)
	
	# load args
        addu    $s0, $zero, $a0        		# s0 = str
        addu    $s1, $zero, $a1        		# s1 = map
	
	# pre loop conditions
        addu    $t0, $zero, $s0        		# t0 = ptr for strlen
        ori     $t1, $zero, 0          		# t1 = length = 0

# loop though every char in the string
strlen_loop:
        lb      $t2, 0($t0)            		# t2 = *t0
        beq     $t2, $zero, strlen_done
        addiu   $t0, $t0, 1            		# t0++
        addiu   $t1, $t1, 1            		# len++
        j       strlen_loop	

strlen_done:
        addiu   $t1, $t1, 1            		# len += 1 to include null terminator

        addiu   $t3, $t1, 3
        ori     $t4, $zero, 3
        nor     $t4, $t4, $zero        		# t4 = ~3 = 0xFFFFFFFC
        and     $t3, $t3, $t4          		# t3 = len_roundUp

        ori     $t5, $zero, 0          		# i = 0

sub_loop:
        beq     $t5, $t1, sub_done     		# if i == len, done
        addu    $t6, $s0, $t5          		# &str[i]
        lb      $t7, 0($t6)            		# t7 = str[i]
        beq     $t7, $zero, add_null   		# if str[i] == 0, go to null handling

        addu    $t8, $s1, $t7          		# &map[str[i]]
        lb      $t9, 0($t8)            		# t9 = map[str[i]]
        addu    $t6, $sp, $t5          		# &dup[i]
        sb      $t9, 0($t6)            		# dup[i] = mapped char
        addiu   $t5, $t5, 1            		# i++
        j       sub_loop

add_null:
        addu    $t6, $sp, $t5          		# &dup[i]
        sb      $zero, 0($t6)          		# dup[i] = '\0'

sub_done:
	# add arg and jump
        addu    $a0, $zero, $sp        		# a0 = &dup[0]
        jal     printSubstitutedString
	
        lw      $ra, 268($sp)          
        lw      $s0, 264($sp)         
        lw      $s1, 260($sp)          
        addiu   $sp, $sp, 272          
        jr      $ra
