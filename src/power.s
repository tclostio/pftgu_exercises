# PURPOSE: Program to illustrate how functions work
#          This program will compute the value of 2^3 + 5^2
#
# Everything in the main program is stored in registers, 
# so the data section is empty.

.section .data

.section .text
    .globl _start

_start:
    pushl $3            # push the second argument (reverse order, remember)
    pushl $2            # push the first argument
    call  power         # call the function
    addl  $8, %esp      # move the stack pointer back
    pushl %eax
#....::SECOND FUNCTION CALL::....#
    pushl $2
    pushl $5
    call  power
    addl  $8, %esp

    popl  %ebx          # the second answer is already in eax, so we can now
                        # pop the first answer out into ebx
    addl  %eax, %ebx    # add them together, and the result remains in ebx

    movl $1, %eax       # load for a linux syscall
    int  $0x80          # and exit (result stored in ebx, called with 'echo $?'

# PURPOSE: This function is used to compute the value of a number raised to a power
#
# INPUT: First arg: base number
#        Second arg: power
#
# OUTPUT: Will give the result as a return value
#
# NOTES: The power must be 1 or greater
#
# VARIABLES: 
#       ebx - holds the base number
#       ecx - holds the power
#       -4(ebp) - holds the current result
#       eax - temp storage
#
.type power, @function
power:
    pushl %ebp          # save the old base pointer
    movl  %esp, %ebp    # make stack pointer the base pointer
    subl  $4, %esp      # get room for our local storage

    movl 8(%ebp), %ebx  # put first argument in eax
    movl 12(%ebp), %ecx # put second argument in ecx

    movl %ebx, -4(%ebp) # store the current result

power_loop_start:
    cmpl $1, %ecx       # check if the power is 1
    je   end_power
    je   ret_one
    movl -4(%ebp), %eax # move the current result into eax
    imull %ebx, %eax    # multiply the current result by the base number
    movl %eax, -4(%ebp) # store the current result

    decl %ecx           # decrease the power, then rerun the loop
    jmp power_loop_start

end_power:
    movl -4(%ebp), %eax # return value goes in eax
    movl %ebp, %esp     # restore the stack pointer
    popl %ebp           # restore the base pointer
    ret
