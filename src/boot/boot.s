.code16
.section .text

KERNEL_MAIN = 0xb000

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

    /* Put the initial page tables at [0x8000, 0xb000) and put the kernel at
     * [0xb000, ...). Note that the second sector contains gargabe, so we start
     * from the third sector (sector 2).
     */
    movw $2, %ax
    movw (sector_count), %bx
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

    call long_mode_activate

    .code64
    movq $KERNEL_MAIN, %rax
    jmp %rax



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
