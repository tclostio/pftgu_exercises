# PURPOSE: This program converts an input file to an output file with uppercase chars
#
# PROCESSING: 1) Open the input file
#             2) Open the output file
#             3) While we're not at the end of the input file:
#                 a) read part of the file into memory
#                    a.1) if the byte is a lower-case letter, convert to upper case
#                 b) write the memory buffer to the output file
#

.section .data

#####CONSTANTS#####

# syscall numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# I/O file operations
.equ O_RDONLY, 0
.equ O_CREATE_WR_ONLY_TRUNC, 03101
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# syscall interrupt
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0 # this is the return value of read which means we've hit the end
                    # of the file
.equ NUMBER_ARGS, 2

.section .bss
# BUFFER_SIZE - this is where the data is loaded into from the data file
# and written from into the output file. This should never exceed 16,000
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE 

.section .text

#####STACK POSITIONS#####
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0         # Number of args
.equ ST_ARGV_0, 4       # Name of program
.equ ST_ARGV_1, 8       # Input file name
.equ ST ARGV_2, 12      # Output file name

.globl _start
_start:
#####INITIALIZE PROGRAM#####
    movl %esp, %ebp             # save the stack pointer
    subl $ST_SIZE_RESERVE, %esp # allocate space for our file descriptors on the stack

    open_files:
    open_fd_in:
    #####OPEN INPUT FILES#####
        movl $SYS_OPEN, %eax            # open syscall
        movl ST_ARGV_1(%ebp), %ebx      # input filename into ebx
        movl $O_RDONLY, %ecx            # read-only flag
        movl $0666, %edx                # this doesn't really matter for reading
        int $LINUX_SYSCALL              # call linux
    store_fd_in:
        movl %eax, ST_FD_IN(%ebp)       # save the given file descriptor
    open_fd_out:
        movl $SYS_OPEN, %eax            # open the file
        movl ST_ARGV_2(%ebp), %ebx      # output filename to ebx
        movl $O_CREATE_RW_ONLY_TRUNC, %ecx # flags for writing the file
        movl $0666, %edx                # mode for new file (if created)
        int $LINUX_SYSCALL              # call linux
    store_fd_out:
        movl %eax, ST_FD_OUT(%ebp)      # store the main file descriptor here
#####BEGIN MAIN LOOP######
    read_loop_begin:

    #####READ IN A BLOCK FROM THE INPUT FILE#####
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx           # get the input file descriptor
    


