# PURPOSE: Simple program that exits and returns a
# status code back to the linux kernel

# INPUT: none

# OUTPUT: returns a status code. This can be viewed by
# typing
#       echo $?
# after running the program.

# VARIABLES:
#       %eax holds the syscall number
#       %ebx holds the return status
#

.section .data

.section .text
.globl _start

_start:
    movl $1, %eax # this is the linux kernel command
                  # number (syscall) for exiting a program.

    movl $0, %ebx # this is the status number we will return
                     # to the OS. Changing it will change the
                     # output after 'echo $?'.

    int $0x80     # this wakes up the kernel.
