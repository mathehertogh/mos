.code16


.section .text

.global _start
_start:
    /* Disable interrupts during boot.
     */
    cli

    /* Save the boot drive number.
     */
    movb %dl, (boot_drive_number)

    /* Set all segment registers to zero.
     */
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    ljmp $0, $1f

1:
    /* Set up a stack for our bootloader at (..., 0x7c00].
     */
    movw $0x7c00, %sp

    /* Print welcome message to the screen.
     */
    movw $msg, %ax
    movw $msg_len, %bx
    call screen_puts

    /* Read the second sector from the disk into [0x7d00, 0x7e00).
     */
    movw $1, %ax
    movw $1, %bx
    movw $0x7d00, %cx
    movw (boot_drive_number), %dx
    call disk_read
    nop
    nop
    nop
    nop

    /* jump to the second stage of our bootloader.
     */
    jmp 0x00007d00
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop


.section .data

msg:
    .ascii "Welcome to Mathe's OS!"
    msg_len = . - msg

boot_drive_number:
    .byte 0x0
