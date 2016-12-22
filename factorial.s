# PURPOSE: Compute the factorial of a given number
#
# This program shows how to call a function recursively
#

.section .data

# This program has no global data

.section .text
    .globl _start
    .globl factorial

_start:
    pushl $4            # The function 'factorial' takes 1 arg, so it gets pushed
    
    call factorial      # run the function
    addl $4, %esp       # scrubs the stack clean of our pushed param

    movl %eax, %ebx     # factorial returns the answer in eax, but we want it in ebx
                        # so we can send it to the exit status syscall
    movl $1, %eax
    int $0x80           # standard exit stuff

# The actual factorial function
.type factorial,@function

factorial:
    pushl %ebp          # restore ebp to its prior state before returning in the function
    movl %esp, %ebp     # we don't want to modify the stack pointer, so we use ebp here
    movl 8(%ebp), %eax  # This moves the first arg to eax,
                        # so 4(ebp) holds the return address and 8(ebp) holds the first param
    cmpl $1, %eax        # if the number is one, that's our base case, so we return
    je end_factorial

    decl %eax           # otherwise, decrement eax by 1 here
    pushl %eax          # push eax for our call to factorial
    call factorial
    
    movl 8(%ebp), %ebx  # eax holds the return value, so we reload are param into ebx
    imull %ebx, %eax     # multiply that by the last call to factorial

end_factorial:
    movl %ebp, %esp     # standard function return, we have to restore ebp and esp to where
                        # they were before the function started
    popl %ebp

    ret                 # return to the function (this pops the return value, too)
