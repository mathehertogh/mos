.code16

KERNEL_NO_SECTORS = 0x7c00 + 512 - 4;

.section .text

.global _start
_start:
    /* Disable interrupts during boot.
     */
    cli
    call nmi_disable

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
    movw $welcome_msg, %ax
    movw $welcome_msg_len, %bx
    call screen_puts

    /* Put the kernel at [0x8000, ...).
     */
    movw $1, %ax
    movw (KERNEL_NO_SECTORS), %bx
    movw $0x8000, %cx
    movw (boot_drive_number), %dx
    call disk_read

    /* Obtain the memory map from the BIOS.
     */
    movw (mmap_entries), %ax
    call mmap_get
    movw %ax, (mmap_size)

    /* In order to access memory above 1MiB, we enable the A20-line.
     */
    call a20_enable

    call protected_mode_activate

    hlt



.section .data

.align 2
mmap:
    mmap_entries: .2byte 0x500
    mmap_size:    .2byte 0x0

boot_drive_number:
    .byte 0x0

welcome_msg:
    .ascii "Welcome to Mathe's OS!"
    welcome_msg_len = . - welcome_msg
