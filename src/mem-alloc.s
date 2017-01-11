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
# We scan through each memory region starting with heap_begin. We look at the size
# of each one, and if it has been allocated. If it's big enough for the requested
# size, and it's available, we grab that one. If it does not find a region large
# enough, it asks Linux for more memory. In that case, it moves current_break up.
#
.globl allocate
.type allocate, @function
.equ ST_MEM_SIZE, 8             # stack position of the memory size to allocate

allocate:
    pushl %ebp
    movl %esp, %ebp

    movl ST_MEM_SIZE(%ebp), %ecx        # ecx will hold the size we are looking for
    movl heap_begin, %eax               # eax will hold the current search location
    movl current_break, %ebx            # ebx will hold the current break
    alloc_loop_begin:                   # here we begin iterating through each region
        cmpl %ebx, %eax                 # need more if these are equal
        je move_break

        # Grab the size of this memory
        movl HDR_SIZE_OFFSET(%eax), %edx
        # If the space is unavailable, go to the next one
        cmpl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
        je next_location

        # If the space is available, compare the size to the needed size
        cmpl %edx, %ecx
        jle allocate_here

    next_location:
        # The total size of the memory region is the sum  of the size requested
        # (currently stored in edx), plus another 8 bytes for the header (4 for
        # the AVAILABLE/UNAVAILABLE flag and 4 for the size of the region). So,
        # adding edx and $8 to eax will get the address of the next memory region.
        addl $HEADER_SIZE, %eax
        addl %edx, %eax

        jmp alloc_loop_begin

    allocate_here:
        # Mark space as unavailable
        movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
        addl $HEADER_SIZE, %eax

        movl %ebp, %esp
        popl %ebp
        ret
    
    # If we made it here, we've exhausted all addressable memory, and we need
    # to ask for more.
    move_break:
        addl $HEADER_SIZE, %ebx
        addl %ecx, %ebx

        pushl %eax
        pushl %ecx
        pushl %ebx

        movl $SYS_BRK, %eax     # reset the break
        int $LINUX_SYSCALL

        cmpl $0, %eax           # check for error conditions
        je error
        
        # Restore saved registers
        popl %ebx
        popl %ecx
        popl %eax

        # Set this memory as unavailable, since we're about to give it away
        movl $UNAVAILABLE, HDR_AVAIL_OFFSET(%eax)
        # Set the size of the memory
        movl %ecx, HDR_SIZE_OFFSET(%eax)
        # Move eax to the actual start of usable memory
        addl $HEADER_SIZE, %eax

        movl %ebx, current_break        # save the new break

        movl %ebp, %esp
        popl %ebp
        ret

    error:
        movl $0, %eax
        movl %ebp, %esp
        popl %ebp
        ret

###END_OF_FUNCTION###
#
###DEALLOCATE###
# 
# Purpose - The purpose of this function is to give back a region of memory to
#           the pool after we're done using it.
#
# Parameters - The only parameter is the address of the memory we want to return
#              to the memory pool.
#
# Return value - There is no return value.
#
# Processing - All we have to do here is go back 8 locations and mark the memory
#              located there as available so that the ALLOCATE function knows it
#              can use it.
#
.globl deallocate
.type deallocate, @function

# Stack position of the memory region to free
.equ ST_MEMORY_SEG, 4
deallocate:
    # Get the address of the memory to free which is normally 8(%ebp), but since 
    # we didn't push ebp or move esp to ebp, we just use 4(%esp)
    movl ST_MEMORY_SEG(%esp), %eax

    # Get the pointer to the real beginning of the memory
    subl $HEADER_SIZE, %eax

    # Mark it as available
    movl $AVAILABLE, HDR_AVAIL_OFFSET(%eax)

    # Finally, return
    ret

###END_OF_FUNCTION###

