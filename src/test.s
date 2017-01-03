; PURPOSE: Tweak a standard 'hello world' program (from a C source)
; VARIABLES: %eax, %ecx, %ebp, %esp
; INPUTS: None.
; OUTPUTS: String "HELLO WORLD".
; AUTHORS: Trent Clostio (twclostio@protonmail.com)

.section .rodata
.LC0:
    .string "HELLO WORLD"
    .text
    .globl _start
    .type  _start, @function

_start:
.LFB0:
    .cfi_startpro
