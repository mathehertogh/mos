.code16
.section .text

/* disk_read
 *
 * Read a number of sectors from a disk into memory.
 *
 * INPUT:
 *   ax - starting sector
 *   bx - number of sectors to read
 *   cx - destination memory address
 *   dx - disk drive number
 */
.global disk_read
disk_read:
	push %si

    /* The following BIOS function will load a number of sectors.
     * http://www.ctyme.com/intr/rb-0708.htm
     * https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=42h:_Extended_Read_Sectors_From_Drive
     */
    movw %ax, (dap_start_sector_lo)
    movw %bx, (dap_no_sectors)
    movw %cx, (dap_load_offset)
    movw $disk_address_packet, %si
    movb $0x42, %ah
    int $0x13

    pop %si
    ret



.section .data

.align 4
disk_address_packet:
    dap_size_of_packet:  .byte 0x10
    dap_reserved_byte:   .byte 0x0
    dap_no_sectors:      .2byte 0x0
    dap_load_offset:     .2byte 0x0
    dap_load_segment:    .2byte 0x0
    dap_start_sector_lo: .4byte 0x0
    dap_start_sector_hi: .4byte 0x0
