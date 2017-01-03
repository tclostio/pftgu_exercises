# PURPOSE: Find the max value in a set of INTs
# VARIABLES:
#       
#       %edi - Holds the index of the data item being examined
#       %ebx - Largest data item found
#       %eax - Current data item
#
# MEMORY_LOCATIONS:
#
#       data_items - Contains the item data, with 0 for termination.
#
# INPUTS: none.
# OUTPUTS: The largest number in the set.
#

.section .data
data_items:             # The list to search
    .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

.section .text

.globl _start
_start:
    movl $0, %edi       # move 0 into the index register
    movl data_items(,%edi,4), %eax # load the first byte of data
    movl %eax, %ebx     # since this is the first item, %eax is the biggest

start_loop:
    cmpl $0, %eax       # check to see if we've hit the 0
    je loop_exit        # and if so, exit the loop
    incl %edi           # load the next value
    movl data_items(,%edi,4), %eax
    cmpl %ebx, %eax     # compare values
    jle start_loop      # jump to the beginning if the new one isn't bigger
    movl %eax, %ebx     # move the larger value
    jmp start_loop      # jump to loop beginning

loop_exit:
    # %ebx is the status code for the exit syscall
    # and it also happens to hold the largest number
    movl $1, %eax
    int $0x80

