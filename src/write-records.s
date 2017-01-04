###IMPORTS###
.include "linux.s"
.include "record-def.s"

###DATA SECTION###
# Contains constant data of the records we want to write. Each text item is padded to
# the proper length with null bytes.
#
# .rept is used to pad each item. .rept tells the assembler to repeat the section
# between .rept and .endr the number of times specified. Here, it's used to add extra
# null characters at the end of each field to fill it.
#
.section .data

record1:
    .ascii "Trent\0"
    .rept 34            # padding to 40 bytes
    .byte 0
    .endr

    .ascii "Clostio\0"
    .rept 32
    .byte 0
    .endr

    .ascii "Pullman, WA\0"
    .rept 228           # padding to 240 bytes
    .byte 0
    .endr

    .long 23            # the subject's age

record2:
    .ascii "Andrea\0"
    .rept 33            # padding to 40 bytes
    .byte 0
    .endr

    .ascii "Connor\0"
    .rept 33
    .byte 0
    .endr

    .ascii "Pullman, WA\0"
    .rept 228
    .byte 0
    .endr

    .long 23            # age

record3:
    .ascii "CJ\0"
    .rept 37
    .byte 0
    .endr

    .ascii "Buresch\0"
    .rept 32
    .byte 0
    .endr

    .ascii "Seattle, WA\0"
    .rept 228
    .byte 0
    .endr

    .long 24            # age

# The file we will write to:
file_name:
    .ascii "test.dat\0"

    .equ ST_FILE_DESCRIPTOR, -4
    .globl _start

_start:
    movl %esp, %ebp             # copy the stack pointer to ebp
    subl $4, %esp               # allocate space for the file descriptor

    # open the file
    movl $SYS_OPEN, %eax
    movl $file_name, %ebx
    movl $0101, %ecx            # create it if it doesn't exist, otherwise open for writing
    movl $0666, %edx
    int $LINUX_SYSCALL

    # store the file descriptor away
    movl %eax, ST_FILE_DESCRIPTOR(%ebp)

    # write the first record
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record1
    call write_record
    addl $8, %esp

    # write the second record
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record2
    call write_record
    addl $8, %esp

    # write the third record
    pushl ST_FILE_DESCRIPTOR(%ebp)
    pushl $record3
    call write_record
    addl $8, %esp

    # close the file descriptor
    movl $SYS_CLOSE, %eax
    movl ST_FILE_DESCRIPTOR(%ebp), %ebx
    int $LINUX_SYSCALL

    # exit the program
    movl $SYS_EXIT, %eax
    movl $0, %ebx
    int $LINUX_SYSCALL


