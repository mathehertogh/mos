.code16


.section .text

.global _start
_start:
    /* Disable interrupts during boot.
     */
    cli

    /* Save the drive number.
     */
    movb %dl, drive_number

    /* Set up a stack for our bootloader at (..., 0x7c00].
     * TODO stack segment?
     */
    movw $0x7c00, %sp

print_welcome_msg:
    /* First clear the screen and make it yellow.
     * http://www.ctyme.com/intr/rb-0097.htm
     */
    movb $0x7, %ah
    movb $0x0, %al
    movb $0xee, %bh
    movw $0x0, %cx
    movw $0xffff, %dx
    int $0x10

    /* Write the welcome message to the screen using EGA.
     * http://www.ctyme.com/intr/rb-0210.htm
     * https://en.wikipedia.org/wiki/INT_10H
     * https://en.wikipedia.org/wiki/Enhanced_Graphics_Adapter
     */
    movw $0x1300, %ax  /* ah: choose "write string" function
                        * al: write mode */
    movw $0x00e4, %bx  /* bh: page number
                        * bl: color (bits 0-3 character, bits 4-7 background) */
    movw $msg_len, %cx /* string length */
    movw $0x0c1b, %dx  /* dh: row
                        * dl: column */
    movw $msg, %bp     /* es:bp: pointer to string */
    int $0x10

load_second_stage:
    /* Load the second stage of our bootloader from disk into memory.
     *
     * The following BIOS function will load a number of sectors.
     * http://www.ctyme.com/intr/rb-0708.htm
     * https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive
     */
    movw $disk_address_packet, %si
    movb $0x42, %ah
    movb drive_number, %dl 
    int $0x13
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

.align 4
disk_address_packet:
    dap_size_of_packet:  .byte 0x10
    dap_reserved_byte:   .byte 0x0
    dap_no_sectors:      .2byte 0x1
    dap_load_offset:     .2byte 0x7d00
    dap_load_segment:    .2byte 0x0
    dap_start_sector_lo: .4byte 0x1
    dap_start_sector_hi: .4byte 0x0

msg:
    .ascii "Welcome to Mathe's OS!"
    msg_len = . - msg

drive_number:
    .byte 0x0