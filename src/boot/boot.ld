OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    /* The BIOS will load the bootloader (i.e. the first sector on the disk) at
     * address 0x7c00 and set cs:ip to 0:0x7c00.
     */
    . = 0x7c00;
    .boot_loader : AT(ADDR(.boot_loader)) {
        *(.text)
        *(.data)
    }

    /* After compiling the kernel, we write the number of sectors that the
     * kernel consists of in these two bytes. The boodloader uses this data to
     * load the kernel into memory.
     */
    . = 0x7c00 + 512 - 4;
    .kernel_no_sectors : AT(ADDR(.kernel_no_sectors)) {
        SHORT(0x0)
    }
    
    /* For the BIOS to recognize the first sector on the disk as a boot laoder,
     * the last two bytes must contain a magic number: the boot signature.
     */
    . = 0x7c00 + 512 - 2;
    .boot_signature : AT(ADDR(.boot_signature)) {
        BYTE(0x55);
        BYTE(0xaa);
    }
}