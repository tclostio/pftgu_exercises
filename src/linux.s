# Common Linux definitions

# SYSCALL numbers
.equ SYS_EXIT, 1
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ SYS_BRK, 45

# SYSCALL interrupt
.equ LINUX_SYSCALL, 0x80

# Standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# Common status codes
.equ EOF, 0