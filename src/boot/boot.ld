OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    /* The BIOS will load the bootloader (i.e. the first sector on the disk) at
     * address 0x7c00 and set cs:ip to 0:0x7c00.
     */
    . = 0x7c00;
    .boot_loader : AT(ADDR(.boot_loader)) {
        *(.text);
        *(.data);
    }

    /* After compiling the kernel, we count the number of sectors that the
     * initial page tables (see below) and the kernel together occupy. We write
     * this count into the following two bytes. The boodloader uses this data to
     * load the page tables and the kernel into memory.
     */
    sector_count = 0x7c00 + 512 - 4;
    . = sector_count;
    .sector_count : AT(ADDR(.sector_count)) {
        SHORT(0x0);
    }
    
    /* For the BIOS to recognize the first sector on the disk as a boot laoder,
     * the last two bytes must contain a magic number: the boot signature.
     */
    . = 0x7c00 + 512 - 2;
    .boot_signature : AT(ADDR(.boot_signature)) {
        BYTE(0x55);
        BYTE(0xaa);
    }



    /* After the bootloader sector, we put the initial page tables.
     * They represent an identity map [0, 2MiB) --> [0, 2MiB).
     */
    pml4 = 0x8000;
    . = pml4;
    .pml4 : AT(ADDR(.pml4)) {
        QUAD(0x9003); /* Present, Writable; first entry points to PTDP at 0x9000 */
        . = 0x1000;
    }
    .ptdp : AT(ADDR(.ptdp)) {
        QUAD(0xa003); /* Present, Writable; first entry points to PTD at 0xa000 */
        . = 0x1000;
    }
    .ptd : AT(ADDR(.ptd)) {
        QUAD(0x83); /* Present, Writable, Huge; first entry points to [0, 2MiB) */
        . = 0x1000;
    }
}