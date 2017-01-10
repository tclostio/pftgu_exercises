# PURPOSE: Program to manage memory usage - allocates and deallocates memory
#          as requested by the programmer.
#
# NOTES: The programs using these routines will ask for a certain size of memory.
#        We actually use more than that size, but we put it at the beginning,
#        before the pointer we hand back. We add a size field and an
#        AVAILABLE/UNAVAILABLE marker. So, the memory ends up looking like this:
#
# ###############################################################
# # AVAILABLE_MARKER | SIZE_OF_MEMORY | ACTUAL_MEMORY_LOCATIONS #
# ###############################################################
#                                      ^-- *returned pointer points here*
#        
#        The pointer we return only points to the actual locations requested to
#        make it easier for the calling program. It also allows us to change our
#        structure without the calling program having to change at all.
#

.section .data

###GLOBAL_VARIABLES###

# This points to the beginning of the memory we are managing
heap_begin:
    .long 0

# This points to one location past the memory we are managing
current_break:
    .long 0

###STRUCTURE_INFORMATION###
# Size of space for memory region header
.equ HEADER_SIZE, 8
# Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0
# Location of the size field in the header
.equ HDR_SIZE_OFFSET, 4

###CONSTANTS###
.equ UNAVAILABLE, 0             # Used to mark space that is given out
.equ AVAILABLE, 1               # Marks space that has been returned
.equ SYS_BRK, 45                # SYSCALL number for the 'break' system call
.equ LINUX_SYSCALL, 0x80        # Linux SYSCALL

.section .text

###FUNCTIONS###
#
###ALLOCATE_INIT###
#
# Purpose - Call this function to initialize the functions (specifically, this
#                 sets heap_begin and current_break). This has no parameters and no
#                 return value.
#
.globl allocate_init
.type allocate_init, @function

allocate_init:
    pushl %ebp
    movl %esp, %ebp

    # If the 'brk' SYSCALL is called with 0 in ebx, it returns the last valid usable
    # address.
    movl $SYS_BRK, %eax         # find out where the break is
    movl $0, %ebx
    int $LINUX_SYSCALL

    incl %eax                   # eax now has the last valid address, and we want the
                                # memory location after that
    movl %eax, current_break    # store the current break
    movl %eax, heap_begin       # store the current break as our first address. This
                                # will cause the allocate function to get more memory
                                # from Linux the first time it is run
    movl %ebp, %esp
    popl %ebp

    ret
###END_OF_FUNCTION###
#
###ALLOCATE###
#
# Purpose - This function is used to grab a section of memory. It checks to see if
#            there are any free blocks, and, if not, it asks Linux for a new one.
#
# Parameters - This function has one parameter: the size of the memory block we want
#              to allocate.
#
# Return value - This function returns the address of the allocated memory in eax.
#                If there is no memory available, it will return 0 in eax.
#
# -Processing-
# Variables used:
#       ecx - hold the size of the requested memory
#       eax - current memory region being examined
#       ebx - current break position
#       edx - size of current memory region
#
#
