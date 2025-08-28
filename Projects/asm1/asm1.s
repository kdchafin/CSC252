.globl studentMain
studentMain:
    # Allocate stack space and save the frame pointer and return address
    addiu $sp, $sp, -24           # Allocate space on stack (24 bytes)
    sw $fp, 0($sp)                 # Save caller's frame pointer
    sw $ra, 4($sp)                 # Save return address
    addiu $fp, $sp, 20             # Set up the frame pointer for this function

.data 
	NOTHING_EQUALS: .asciiz "NOTHING EQUALS\n"
	EQUALS: .asciiz "EQUALS\n"                  
	ALL_EQUAL: .asciiz "ALL EQUAL\n"           
	ASCENDING: .asciiz "ASCENDING\n"     
	DESCENDING: .asciiz "DESCENDING\n"     
	UNORDERED: .asciiz "UNORDERED\n"            
	REVERSE: .asciiz "REVERSE\n"            
	RED: .asciiz "red: "                   
	ORANGE: .asciiz "orange: "         
	YELLOW: .asciiz "yellow: "            
	GREEN: .asciiz "green: "            
	BLUE: .asciiz "blue: "              
	PURPLE: .asciiz "purple: "                 
	NEWLINE: .asciiz " \n"                    

.text 
    # Set operation flags (1 or 0)
    la      $t0, equals         # t0 = &equals
    lw      $t0, 0($t0)         # t0 = equals
    la      $t1, order          # t1 = &order
    lw      $t1, 0($t1)         # t1 = order
    la      $t2, reverse        # t2 = &reverse
    lw      $t2, 0($t2)         # t2 = reverse
    la      $t3, print          # t3= &print
    lw      $t3, 0($t3)         # t3 = print
    
    if_equal:
        beq     $t0, $zero, if_order    # if (t0 == 0) jump to if_order

        # Load registers with color values
        la      $t0, red                # t0 = &red
        lw      $s0, 0($t0)             # s0 = red
        la      $t0, orange             # t0 = &orange
        lw      $s1, 0($t0)             # s1 = orange
        la      $t0, yellow             # t0 = &yellow
        lw      $s2, 0($t0)             # s2 = yellow
        la      $t0, green              # t0 = &green
        lw      $s3, 0($t0)             # s3 = green

    	# Exhaustive equality check
    	beq     $s0, $s1, print_equal   # if (s0 == s1) jump to print_equal
    	beq     $s0, $s2, print_equal   # if (s0 == s2) jump to print_equal
    	beq     $s0, $s3, print_equal   # if (s0 == s3) jump to print_equal
    	beq     $s1, $s2, print_equal   # if (s1 == s2) jump to print_equal
    	beq     $s1, $s3, print_equal   # if (s1 == s3) jump to print_equal
    	beq     $s2, $s3, print_equal   # if (s2 == s4) jump to print_equal
    	
    	print_not_equal:
        addi    $v0, $zero, 4           # print "NOT EQUAL\n"
        la      $a0, NOTHING_EQUALS  
        syscall                  
        j       if_order                # Jump to order check
                
        print_equal:
        addi    $v0, $zero, 4           # print "EQUAL\n"
        la      $a0, EQUALS           
        syscall
    
    if_order:
        beq     $t1, $zero, if_reverse  # if (t1 == 0) jump to if_reverse
            
        # Load registers with color values
        la      $t0, red                # t0 = &red
        lw      $s0, 0($t0)             # s0 = red
        la      $t0, orange             # t0 = &orange
        lw      $s1, 0($t0)             # s1 = orange
        la      $t0, yellow             # t0 = &yellow
        lw      $s2, 0($t0)             # s2 = yellow
        la      $t0, green              # t0 = &green
        lw      $s3, 0($t0)             # s3 = green
        la      $t0, blue               # t5 = &blue
        lw      $s4, 0($t0)             # t5 = blue
        la      $t0, purple             # t4 = &purple
        lw      $s5, 0($t0)             # t4 = purple

        # Check if all registers are equal using bne (branch if not equal)
        bne     $s0, $s1, continue      # if (s0 != s1) jump to continue
        bne     $s0, $s2, continue      # if (s0 != s2) jump to continue
        bne     $s0, $s3, continue      # if (s0 != s3) jump to continue
        bne     $s0, $s4, continue      # if (s1 != s2) jump to continue
        bne     $s0, $s5, continue      # if (s1 != s3) jump to continue
        # If none of the bne branches were taken, all values are equal
        j       all_equal             # jump to print_equal if all values are equal

        continue:
        # Ascending check (allow equal values)
        slt     $t5, $s0, $s1           # t5 = (s0 < s1)
        slt     $t6, $s1, $s2           # t5 = (s1 < s2)
        slt     $t7, $s2, $s3           # t5 = (s2 < s3)
        slt     $t8, $s3, $s4           # t5 = (s3 < s4)
        slt     $t9, $s4, $s5           # t5 = (s4 < s5)
        
        # Combine results for ascending check
        or      $t0, $t5, $t6           # red < orange || orange < yellow
        or      $t0, $t0, $t7           # t0 || yellow < green
        or      $t0, $t0, $t8           # t0 || green < blue
        or      $t0, $t0, $t9           # t0 || blue < purple
        
        # If t0 is non-zero, it's not strictly ascending order
        beq     $t0, $zero, descending  # if (t0 == 0) jump to descending

        # Descending check (allow equal values)
        slt     $t5, $s1, $s0           # t5 = (s1 < s0)
        slt     $t6, $s2, $s1           # t5 = (s2 < s1)
        slt     $t7, $s3, $s2           # t5 = (s3 < s2)
        slt     $t8, $s4, $s3           # t5 = (s4 < s3)
        slt     $t9, $s5, $s4           # t5 = (s5 < s4)

        # Combine results for descending check
        or      $t1, $t5, $t6           # orange < red || yellow < orange
        or      $t1, $t1, $t7           # t1 || green < yellow
        or      $t1, $t1, $t8           # t1 || blue < green
        or      $t1, $t1, $t9           # t1 || purple < blue
        
        # If t1 is non-zero, it's not strictly descending order
        beq     $t1, $zero, ascending   # if (t1 == 0) jump to ascending

        addi    $v0, $zero, 4           #print "UNORDERED\n" 
        la      $a0, UNORDERED       
        syscall                    
        j       if_reverse              # jump to if_reverse
                
        ascending:
        addi    $v0, $zero, 4           #print "ASCENDING\n" 
        la      $a0, ASCENDING       
        syscall                    
        j       if_reverse              # jump to if_reverse
           
        descending:
        addi    $v0, $zero, 4           #print "DESCENDING\n" 
        la      $a0, DESCENDING       
        syscall                    
        j       if_reverse              # jump to if_reverse
           
        all_equal:
        addi    $v0, $zero, 4           #print "ALL_EQUAL\n" 
        la      $a0, ALL_EQUAL       
        syscall                    
        j       if_reverse              # jump to if_reverse
           

    if_reverse:
        beq     $t2, $zero, if_print    # If reverse flag is 0, skip to printing the colors

        # Reverse the colors
        la      $t9, red                # t9 = & red   
        lw      $t9, 0($t9)             # t9 = red
        la      $t8, orange             # t8 = &orange
        lw      $t8, 0($t8)             # t8 = orange
        la      $t7, yellow             # t7 = &yellow
        lw      $t7, 0($t7)             # t7 = yellow
        la      $t6, green              # t6 = &green
        lw      $t6, 0($t6)             # t6 = green
        la      $t5, blue               # t5 = &blue
        lw      $t5, 0($t5)             # t5 = blue
        la      $t4, purple             # t4 = &purple
        lw      $t4, 0($t4)             # t4 = purple

        # Store reversed colors back
        la      $t0, purple             # t0 = &purple
        sw      $t9, 0($t0)             # &purple = red
        la      $t0, blue               # t0 = &blue
        sw      $t8, 0($t0)             # &blue = orange    
        la      $t0, green              # t0 = &green
        sw      $t7, 0($t0)             # &green = yellow
        la      $t0, yellow             # t0 = &yellow
        sw      $t6, 0($t0)             # &yellow = green
        la      $t0, orange             # t0 = &orange
        sw      $t5, 0($t0)             # &orange = blue
        la      $t0, red                # t0 = &red
        sw      $t4, 0($t0)             # &red = purple

        # Print reverse message
        addi    $v0, $zero, 4           # print "REVERSE\n"
        la      $a0, REVERSE
        syscall
     
    if_print:
        beq     $t3, $zero, end_if      # if (t3 == 0) jump to end_if
        
        # Load registers with color values
        la      $t0, red                # t0 = &red
        lw      $s0, 0($t0)             # s0 = red
        la      $t0, orange             # t0 = &orange
        lw      $s1, 0($t0)             # s1 = orange
        la      $t0, yellow             # t0 = &yellow
        lw      $s2, 0($t0)             # s2 = yellow
        la      $t0, green              # t0 = &green
        lw      $s3, 0($t0)             # s3 = green
        la      $t0, blue               # t0 = &blue
        lw      $s4, 0($t0)             # s4 = blue
        la      $t0, purple             # t0 = &purple
        lw      $s5, 0($t0)             # s5 = purple

        addi    $v0, $zero, 4           # print "red: " + red + "\n"
        la      $a0, RED        
        syscall
        addi    $v0, $zero, 1  
        add     $a0, $zero, $s0 
        syscall
        addi    $v0, $zero, 4   
        la      $a0, NEWLINE    
        syscall

        addi    $v0, $zero, 4           # print "orange: " + orange + "\n"
        la      $a0, ORANGE     
        syscall
        addi    $v0, $zero, 1   
        add     $a0, $zero, $s1
        syscall
        addi    $v0, $zero, 4  
        la      $a0, NEWLINE    
        syscall

        addi    $v0, $zero, 4           # print "yellow: " + yellow + "\n"
        la      $a0, YELLOW     
        syscall
        addi    $v0, $zero, 1   
        add     $a0, $zero, $s2 
        syscall
        addi    $v0, $zero, 4   
        la      $a0, NEWLINE    
        syscall

        addi    $v0, $zero, 4           # print "green: " + green + "\n"
        la      $a0, GREEN      
        syscall
        addi    $v0, $zero, 1   
        add     $a0, $zero, $s3 
        syscall
        addi    $v0, $zero, 4   
        la      $a0, NEWLINE   
        syscall

        addi    $v0, $zero, 4           # print "blue: " + blue + "\n"
        la      $a0, BLUE       
        syscall
        addi    $v0, $zero, 1  
        add     $a0, $zero, $s4
        syscall
        addi    $v0, $zero, 4   
        la      $a0, NEWLINE    
        syscall

        addi    $v0, $zero, 4           # print "purple: " + purple + "\n"
        la      $a0, PURPLE     
        syscall
        addi    $v0, $zero, 1   
        add     $a0, $zero, $s5 
        syscall
        addi    $v0, $zero, 4  
        la      $a0, NEWLINE   
        syscall
        
    end_if:
        # Restore the return address and frame pointer before returning
        lw      $ra, 4($sp)         # Load return address from stack
        lw      $fp, 0($sp)         # Restore caller's frame pointer
        addiu   $sp, $sp, 24     # Restore the caller's stack pointer
        jr      $ra                 # Jump to the return address
