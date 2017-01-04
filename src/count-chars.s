#---------------------------------------------------------|
# PURPOSE: Count characters until a null byte is reached. |
#                                                         |
# INPUT: The address of the character string.             |
#                                                         |
# OUPUT: Returns the count in eax                         |
#                                                         |
# PROCESS:                                                |
#                                                         |
#       Registers Used:                                   |
#               ecx: character count                      |
#               al: current character                     |
#               edx: current character address            |
#---------------------------------------------------------|

###FUNCTION DEFINITIONS###
.type count_chars, @function
.globl count_chars

.equ ST_STRING_START_ADDRESS, 8         # where our one parameter is on the stack

count_chars:
    pushl %ebp
    movl %esp, %ebp

    # counter starts at 0
    movl $0, %ecx

    # starting address of data
    movl ST_STRING_START_ADDRESS(%ebp), %edx

count_loop_begin:
    movb (%edx), %al                    # grab the current char
    cmpb $0, %al                        # check if null
    je count_loop_end                   # if so, we're done

    # otherwise, increment the counter and the pointer, and jump to the beginning
    # of the loop.
    incl %ecx
    incl %edx
    jmp count_loop_begin

count_loop_end:
    # We're done. Move the count into eax and return.
    movl %ecx, %eax

    popl %ebp
    ret

